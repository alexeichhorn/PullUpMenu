//
//  CustomAnimator.swift
//  JetMusic
//
//  Created by Alexander Eichhorn on 22.09.18.
//  Copyright © 2018 Losjet - Alexander Eichhorn. All rights reserved.
//

import UIKit

open class CustomAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration: TimeInterval
    
    public init(duration: TimeInterval) {
        self.duration = duration
        
        super.init()
    }
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fatalError("implement transition in subclass")
    }
    
}
