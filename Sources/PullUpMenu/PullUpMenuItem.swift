//
//  PullUpMenuItem.swift
//  MusicPullUpMenuTest
//
//  Created by Alexander Eichhorn on 26.07.19.
//  Copyright © 2019 Losjet - Alexander Eichhorn. All rights reserved.
//

import UIKit

public class PullUpMenuItem {
    let title: String
    let subtitle: String?
    let image: UIImage?
    let tintColor: UIColor
    var touchUpInsideHandler: (() -> Void)? = nil
    
    init(title: String, subtitle: String? = nil, image: UIImage?, tintColor: UIColor = .black, touchUpInsideHandler: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.tintColor = tintColor
        self.touchUpInsideHandler = touchUpInsideHandler
    }
}
