//
//  PullUpMenuInteractionController.swift
//  MusicPullUpMenuTest
//
//  Created by Alexander Eichhorn on 27.07.19.
//  Copyright © 2019 Losjet - Alexander Eichhorn. All rights reserved.
//

import UIKit

open class PullUpMenuInteractionController: UIPercentDrivenInteractiveTransition {
    
    open var inProgress = false
    
    private var isPresenting = false
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    private weak var transitionContext: UIViewControllerContextTransitioning?
    private var presentationClosure: (() -> Void)?
    
    public init(isPresenting: Bool, viewController: UIViewController, gestureDelegate: UIGestureRecognizerDelegate? = nil, whenPresenting presentationClosure: (() -> Void)? = nil) {
        super.init()
        
        self.isPresenting = isPresenting
        self.viewController = viewController
        self.presentationClosure = presentationClosure
        self.completionCurve = .linear
        
        self.setupGestureRecognizer(in: viewController.view, withDelegate: gestureDelegate)
    }
    
    private func setupGestureRecognizer(in view: UIView, withDelegate gestureDelegate: UIGestureRecognizerDelegate?) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        pan.delegate = gestureDelegate
        view.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translate = gesture.translation(in: gesture.view)
        let percent = (isPresenting ? -1 : 1) * translate.y / gesture.view!.bounds.size.height
        //print("percent: \(percent)")
        
        switch gesture.state {
        case .began:
            inProgress = true
            if isPresenting {
                presentationClosure?()
            } else {
                viewController.dismiss(animated: true, completion: nil)
            }
        
        case .changed:
            self.update(percent)
            
        case .cancelled:
            inProgress = false
            self.cancel()
            
        case .ended:
            inProgress = false
            
            let velocity = gesture.velocity(in: gesture.view)
            let projected = translate.y + project(initalVelocity: velocity.y)
            let projectedPercent = (isPresenting ? -1 : 1) * projected / gesture.view!.bounds.size.height
            print("projected percent: \(projectedPercent) from current: \(percent)")
            
            completionCurve = .easeOut
            
            if projectedPercent > 0.4 {
                completionDuration = (1-percent)*duration
                self.finish()
            } else {
                completionDuration = percent*duration
                self.cancel()
            }
        
        default:
            break
        }
    }
    
    
    // MARK: - Layer Animation Handling
    
    private var completionDuration: CGFloat = 0
    
    
    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
        pauseAllLayers()
    }
    
    open override func update(_ percentComplete: CGFloat) {
        super.update(percentComplete)
        let percentComplete = max(min(percentComplete, 1), 0)
        containerLayers.forEach({ $0.timeOffset = CFTimeInterval(duration*percentComplete) })
    }
    
    open override func cancel() {
        super.cancel()
        guard completionDuration > 0 else { return }
        
        for layer in containerLayers {
            layer.speed = -1
            layer.beginTime = CACurrentMediaTime()
        }
    }
    
    open override func finish() {
        super.finish()
        resumeAllLayers()
    }
    
    
    func pauseLayer(_ layer: CALayer) {
        layer.speed = 0
        layer.timeOffset = 0
    }
    
    func pauseAllLayers() {
        containerLayers.forEach({ pauseLayer($0) })
    }
    
    func resumeLayer(_ layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    func resumeAllLayers() {
        containerLayers.forEach({ resumeLayer($0) })
    }
    
    
    
    /// layers with interactive CAAnimations
    private var containerLayers: [CALayer] {
        guard let transitionContext = transitionContext else { return [] }
        
        var layers = transitionContext.containerView.subviews.compactMap({ ($0 as? AnimatablePullUpButton)?.animatedLayer })
        
        if let topVC = transitionContext.viewController(forKey: isPresenting ? .to : .from) as? PullUpMenuController {
            layers += [topVC.dismissButton.animatedLayer]
        }
        
        return layers
    }
    
    
    // MARK: -
    
    /// Distance traveled after decelerating to zero velocity at a constant rate
    private func project(initalVelocity: CGFloat, decelerationRate: CGFloat = 0.996/*UIScrollView.DecelerationRate.normal.rawValue*/) -> CGFloat {
        return (initalVelocity / 1000) * decelerationRate / (1 - decelerationRate)
    }
    
}
