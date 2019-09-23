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
}

public class PullUpMenuItem {
    let title: String
    let subtitle: String?
    let image: UIImage?
    let tintColor: UIColor
    var touchUpInsideHandler: (() -> Void)? = nil
    
    weak var delegate: PullUpMenuItemDelegate?
    
    public var isActive = false {
        didSet {
            delegate?.menuItemIsActiveDidChange()
        }
    }
    
    public init(title: String, subtitle: String? = nil, image: UIImage?, tintColor: UIColor = .black, isActive: Bool = false, touchUpInsideHandler: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.tintColor = tintColor
        self.isActive = isActive
        self.touchUpInsideHandler = touchUpInsideHandler
    }
}
