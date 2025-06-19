//
//  CameraView.swift
//  Snapcook-CoreML
//
//  Created by Naela Fauzul Muna on 19/06/25.
//

import SwiftUI
import Combine
import AVFoundation

struct CameraView: View {
    @StateObject var model = CameraViewModel()
    
    var captureButton: some View {
        Button(action: {
            model.capturePhoto()
        }, label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 65, height: 65, alignment: .center)
                )
        })
    }
    
    var capturedPhotoThumbnail: some View {
        Group {
            if let photo = model.photo, let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .animation(.spring, value: 1)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60, alignment: .center)
                    .foregroundColor(.black)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { reader in
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Button(action: {
                            model.switchFlash()
                        }, label: {
                            Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .font(.system(size: 20, weight: .medium, design: .default))
                        })
                        .accentColor(model.isFlashOn ? .yellow : .white)
                        
                        CameraPreview(session: model.session)
                            .onAppear {
                                model.configure()
                            }
                            .alert(isPresented: $model.showAlertError, content: {
                                Alert(title: Text(model.alertError.title), message: Text(model.alertError.message), dismissButton: .default(Text(model.alertError.primaryButtonTitle), action: {
                                    model.alertError.primaryAction?()
                                }))
                            })
                            .overlay(
                                Group {
                                    if model.willCapturePhoto {
                                        Color.black
                                    }
                                }
                            )
                            .animation(.easeInOut, value: 0.5)
                        
                        HStack {
                            NavigationLink(
                                destination: PhotoPreviewView(photo: model.photo),
                                isActive: Binding(
                                    get: { model.photo != nil },
                                    set: { if !$0 { model.photo = nil } }
                                )
                            ) {
                                capturedPhotoThumbnail
                            }
                            
                            Spacer()
                            
                            captureButton
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}


#Preview {
    CameraView()
}

