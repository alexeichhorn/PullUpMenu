//
//  PullUpMenuItem.swift
//  MusicPullUpMenuTest
//
//  Created by Alexander Eichhorn on 26.07.19.
//  Copyright © 2019 Losjet - Alexander Eichhorn. All rights reserved.
//

import UIKit

protocol PullUpMenuItemDelegate: class {
    func menuItemIsActiveDidChange()
    func menuItemSubtitleDidChange()
}

public class PullUpMenuItem {
    public let title: String
    public let identifier: String
    public let image: UIImage?
    public let tintColor: UIColor
    public var touchUpInsideHandler: (() -> Void)? = nil
    
    weak var delegate: PullUpMenuItemDelegate?
    
    public var subtitle: String? {
        didSet {
            delegate?.menuItemSubtitleDidChange()
        }
    }
    
    public var isActive = false {
        didSet {
            delegate?.menuItemIsActiveDidChange()
        }
    }
    
    /// - parameter touchUpInsideHandler: don't use strong reference inside closure
    public init(title: String, subtitle: String? = nil, identifier: String = UUID().uuidString, image: UIImage?, tintColor: UIColor = .black, isActive: Bool = false, touchUpInsideHandler: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.identifier = identifier
        self.image = image
        self.tintColor = tintColor
        self.isActive = isActive
        self.touchUpInsideHandler = touchUpInsideHandler
    }
    
    /// is invisible, only takes up space. Can be used as a placeholder
    public static let empty = PullUpMenuItem(title: "", image: nil)
}
