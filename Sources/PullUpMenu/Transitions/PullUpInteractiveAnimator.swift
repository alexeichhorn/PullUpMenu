//
//  PullUpInteractiveAnimator.swift
//  
//
//  Created by Alexander Eichhorn on 06.10.19.
//

import UIKit

public class PullUpInteractiveAnimator {
    
    public private(set) var inProgress = false
    
    private var isPresenting = false
    private var menuGenerator: (() -> PullUpMenuController)?
    private weak var viewController: UIViewController!
    private weak var menuController: PullUpMenuController?
    
    public init(viewController: UIViewController, menuGenerator: @escaping () -> PullUpMenuController, gestureDelegate: UIGestureRecognizerDelegate? = nil) {
        self.isPresenting = true
        self.viewController = viewController
        self.menuGenerator = menuGenerator
        
        setupGestureRecognizer(in: viewController.view, withDelegate: gestureDelegate)
    }
    
    init(menuController: PullUpMenuController, gestureDelegate: UIGestureRecognizerDelegate? = nil) {
        self.isPresenting = false
        self.menuController = menuController
        
        setupGestureRecognizer(in: menuController.view, withDelegate: gestureDelegate)
    }
    
    private func setupGestureRecognizer(in view: UIView, withDelegate gestureDelegate: UIGestureRecognizerDelegate?) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        pan.delegate = gestureDelegate
        view.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translate = gesture.translation(in: gesture.view)
        let percent = (isPresenting ? -1 : 1) * translate.y / gesture.view!.bounds.size.height
        print("percent: \(percent)")
        
        switch gesture.state {
        case .began:
            inProgress = true
            if isPresenting {
                openMenuController()
                menuController?.animator.createAnimation()
                
            } else {
                menuController?.animator.createAnimation()
            }
            
        case .changed:
            menuController?.animator.updateInteractive(percentComplete: percent)
            
        case .cancelled:
            inProgress = false
            menuController?.animator.cancel()
            
        case .ended:
            inProgress = false
            
            let velocity = gesture.velocity(in: gesture.view)
            let projected = translate.y + project(initalVelocity: velocity.y)
            let projectedPercent = (isPresenting ? -1 : 1) * projected / gesture.view!.bounds.size.height
            print("projected percent: \(projectedPercent) from current: \(percent)")
            
            if projectedPercent > 0.4 {
                let fractionRemaining = 1 - percent
                let distanceRemaining = fractionRemaining * (menuController?.view.frame.height ?? 1)
                let relativeVelocity = min(abs(velocity.y) / distanceRemaining, 30)
                menuController?.animator.finish(relativeVelocity: relativeVelocity)
            } else {
                menuController?.animator.cancel()
            }
            
        default:
            break
        }
    }
    
    
    private func openMenuController() {
        let menuController = menuGenerator?()
        menuController?.present(in: viewController, animated: false)
        self.menuController = menuController // save in seperate variable to make sure menuController doesn't get deallocated before presented
    }
    
    
    // MARK: -
    
    /// Distance traveled after decelerating to zero velocity at a constant rate
    private func project(initalVelocity: CGFloat, decelerationRate: CGFloat = 0.996/*UIScrollView.DecelerationRate.normal.rawValue*/) -> CGFloat {
        return (initalVelocity / 1000) * decelerationRate / (1 - decelerationRate)
    }
    
}
