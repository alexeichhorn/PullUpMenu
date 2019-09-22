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

extension UISpringTimingParameters {
    
    /// A design-friendly way to create a spring timing curve.
    ///
    /// - Parameters:
    ///   - damping: The 'bounciness' of the animation. Value must be between 0 and 1.
    ///   - response: The 'speed' of the animation.
    ///   - initialVelocity: The vector describing the starting motion of the property. Optional, default is `.zero`.
    public convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
    
}
