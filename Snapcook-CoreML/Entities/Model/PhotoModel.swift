//
//  PhotoModel.swift
//  Snapcook-CoreML
//
//  Created by Naela Fauzul Muna on 19/06/25.
//

import Foundation
import UIKit

public struct Photo: Identifiable, Equatable {
    public var id: String
    public var originalData: Data
    
    public init(id: String = UUID().uuidString, originalData: Data) {
        self.id = id
        self.originalData = originalData
    }
}

extension Photo {
    public var image: UIImage? {
        return UIImage(data: originalData)
    }
}
