//
//  CameraManager.swift
//  Snapcook-CoreML
//
//  Created by Naela Fauzul Muna on 19/06/25.
//

import Foundation
import Combine
import AVFoundation
import Photos
import UIKit

public class CameraService {
    typealias PhotoCaptureSessionID = String
    
    // Observed Properties
    @Published public var flashMode: AVCaptureDevice.FlashMode = .off
    @Published public var shouldShowAlertView = false
    @Published public var shouldShowSpinner = false
    @Published public var willCapturePhoto = false
    @Published public var isCameraButtonDisabled = true
    @Published public var isCameraUnavailable = true
    @Published public var photo: Photo?
    
    // Alert properties
    public var alertError: AlertError = AlertError()
    
    // Session Management Properties
    public let session = AVCaptureSession()
    var isSessionRunning = false
    var isConfigured = false
    var setupResult: SessionSetupResult = .success
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    // Device Configuration Properties
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
    
    // Capturing Photos
    private let photoOutput = AVCapturePhotoOutput()
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    
    // KVO and Notifications Properties
    private var keyValueObservations = [NSKeyValueObservation]()
    
    public func configure() {
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    public func checkForPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            setupResult = .notAuthorized
            DispatchQueue.main.async {
                self.alertError = AlertError(title: "Camera Access", message: "SwiftCamera doesn't have access to use your camera, please update your privacy settings.", primaryButtonTitle: "Settings", secondaryButtonTitle: nil, primaryAction: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }, secondaryAction: nil)
                self.shouldShowAlertView = true
                self.isCameraUnavailable = true
                self.isCameraButtonDisabled = true
            }
        }
    }
    
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        // Add video input (hanya kamera belakang)
        do {
            guard let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("Back camera is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: backCameraDevice)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                print("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
//            photoOutput.maxPhotoDimensions = CGSize(width: 1280, height: 720)
            photoOutput.maxPhotoQualityPrioritization = .quality
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
        self.isConfigured = true
        self.start()
    }
    
    public func focus(at focusPoint: CGPoint) {
        let device = self.videoDeviceInput.device
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .continuousAutoExposure
                device.focusMode = .continuousAutoFocus
                device.unlockForConfiguration()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func stop(completion: (() -> ())? = nil) {
        sessionQueue.async {
            if self.isSessionRunning {
                if self.setupResult == .success {
                    self.session.stopRunning()
                    self.isSessionRunning = self.session.isRunning
                    
                    if !self.session.isRunning {
                        DispatchQueue.main.async {
                            self.isCameraButtonDisabled = true
                            self.isCameraUnavailable = true
                            completion?()
                        }
                    }
                }
            }
        }
    }
    
    public func start() {
        sessionQueue.async {
            if !self.isSessionRunning && self.isConfigured {
                switch self.setupResult {
                case .success:
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                    
                    if self.session.isRunning {
                        DispatchQueue.main.async {
                            self.isCameraButtonDisabled = false
                            self.isCameraUnavailable = false
                        }
                    }
                case .configurationFailed, .notAuthorized:
                    print("Application not authorized to use camera")
                    DispatchQueue.main.async {
                        self.alertError = AlertError(title: "Camera Error", message: "Camera configuration failed. Either your device camera is not available or its missing permissions", primaryButtonTitle: "Accept", secondaryButtonTitle: nil, primaryAction: nil, secondaryAction: nil)
                        self.shouldShowAlertView = true
                        self.isCameraButtonDisabled = true
                        self.isCameraUnavailable = true
                    }
                }
            }
        }
    }
    
    public func capturePhoto() {
        if self.setupResult != .configurationFailed {
            self.isCameraButtonDisabled = true
            
            sessionQueue.async {
                if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                    photoOutputConnection.videoRotationAngle = 90
                }
                var photoSettings = AVCapturePhotoSettings()
                
                if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                    photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
                }
                
                if self.videoDeviceInput.device.isFlashAvailable {
                    photoSettings.flashMode = self.flashMode
                }
                
                photoSettings.isHighResolutionPhotoEnabled = true
                
                if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                    photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
                }
                
                photoSettings.photoQualityPrioritization = .quality
                
                let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: { [weak self] in
                    DispatchQueue.main.async {
                        self?.willCapturePhoto = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        self?.willCapturePhoto = false
                    }
                }, completionHandler: { [weak self] (photoCaptureProcessor) in
                    if let data = photoCaptureProcessor.photoData {
                        self?.photo = Photo(originalData: data)
                        print("Photo captured")
                    } else {
                        print("No photo data")
                    }
                    
                    self?.isCameraButtonDisabled = false
                    
                    self?.sessionQueue.async {
                        self?.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                    }
                }, photoProcessingHandler: { [weak self] animate in
                    if animate {
                        self?.shouldShowSpinner = true
                    } else {
                        self?.shouldShowSpinner = false
                    }
                })
                
                self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
                self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
            }
        }
    }
}
