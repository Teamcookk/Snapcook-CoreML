//
//  AlertError.swift
//  Snapcook-CoreML
//
//  Created by Naela Fauzul Muna on 19/06/25.
//

import Foundation

public struct AlertError {
    public let title: String
    public let message: String
    public let primaryButtonTitle: String
    public let secondaryButtonTitle: String?
    public let primaryAction: (() -> Void)?
    public let secondaryAction: (() -> Void)?
    
    public init(
        title: String = "",
        message: String = "",
        primaryButtonTitle: String = "Accept",
        secondaryButtonTitle: String? = nil,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
}
