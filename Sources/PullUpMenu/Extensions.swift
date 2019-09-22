//
//  Extensions.swift
//  MusicPullUpMenuTest
//
//  Created by Alexander Eichhorn on 27.07.19.
//  Copyright © 2019 Losjet - Alexander Eichhorn. All rights reserved.
//

import UIKit


extension CGSize {
    
    func extended(by insets: UIEdgeInsets) -> CGSize {
        return CGSize(width: width+insets.left+insets.right, height: height+insets.top+insets.bottom)
    }
    
}
