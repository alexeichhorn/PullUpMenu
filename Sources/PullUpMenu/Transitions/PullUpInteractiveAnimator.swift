//
//  PullUpInteractiveAnimator.swift
//  
//
//  Created by Alexander Eichhorn on 06.10.19.
//

import UIKit
import os.log

@MainActor
public class PullUpInteractiveAnimator {
    
    public private(set) var inProgress = false
    
    private var isPresenting = false
    private var menuGenerator: (() -> PullUpMenuController)?
    private weak var viewController: UIViewController!
    private weak var menuController: PullUpMenuController?
    
    private var inversedPercent = false
    private var percentOffset: CGFloat = 0.0
    
    private let log = OSLog(subsystem: "PullUpMenu", category: String(describing: PullUpInteractiveAnimator.self))
    
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
        pan.name = "pullUpMenu" // for later identification
        pan.delegate = gestureDelegate
        view.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translate = gesture.translation(in: gesture.view)
        let percent = (inversedPercent ? -1 : 1) * (isPresenting ? -1 : 1) * translate.y / gesture.view!.bounds.size.height + percentOffset
        //print("percent: \(percent)")
        
        switch gesture.state {
        case .began:
            guard panEnabled else { return }
            inProgress = true
            
            if menuController?.animator.isRunning ?? false {
                percentOffset = menuController?.animator.currentFractionComplete ?? 0
                inversedPercent = (menuController?.animator.state == .closed && !isPresenting) || (menuController?.animator.state == .opened && isPresenting)
                print("percent offset: \(percentOffset)")
            } else {
                percentOffset = 0
                inversedPercent = false
            }
            
            if isPresenting {
                if !(menuController?.animator.isRunning ?? false) {
                    openMenuController()
                }
                menuController?.animator.createAnimation(preloadDestination: true)
                
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
            let projectedPercent = (inversedPercent ? -1 : 1) * (isPresenting ? -1 : 1) * projected / gesture.view!.bounds.size.height + percentOffset
            os_log("projected percent: %{public}.4f from current: %{public}.4f", log: log, type: .debug, projectedPercent, percent)
            
            if projectedPercent > 0.4 {
                let fractionRemaining = 1 - percent
                let distanceRemaining = fractionRemaining * (menuController?.view.frame.height ?? 1)
                let relativeVelocity = min(abs(velocity.y) / distanceRemaining, 30)
                menuController?.animator.finish(relativeVelocity: relativeVelocity)
            } else {
                print("cancel")
                menuController?.animator.cancel(animated: percent > 0)
            }
            
        default:
            break
        }
    }
    
    
    private func openMenuController() {
        guard self.menuController == nil else { return }
        
        let menuController = menuGenerator?()
        menuController?.present(in: viewController, animated: false)
        self.menuController = menuController // save in seperate variable to make sure menuController doesn't get deallocated before presented
    }
    
    
    // MARK: - Regular Size Handling
    
    /// when enabled, the menu controller can't be interactively opened when in popover mode. (default: disabled)
    /// - note: recommended whenever you enabled popover mode in menu controller
    public var disableOnPopover: Bool = false
    
    private var panEnabled: Bool {
        !disableOnPopover || viewController.traitCollection.horizontalSizeClass != .regular
    }
    
    
    // MARK: -
    
    /// Distance traveled after decelerating to zero velocity at a constant rate
    private func project(initalVelocity: CGFloat, decelerationRate: CGFloat = 0.996/*UIScrollView.DecelerationRate.normal.rawValue*/) -> CGFloat {
        return (initalVelocity / 1000) * decelerationRate / (1 - decelerationRate)
    }
    
}
