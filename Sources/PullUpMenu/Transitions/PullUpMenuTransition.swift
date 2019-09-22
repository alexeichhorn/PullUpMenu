//
//  PullUpMenuTransition.swift
//  MusicPullUpMenuTest
//
//  Created by Alexander Eichhorn on 27.07.19.
//  Copyright © 2019 Losjet - Alexander Eichhorn. All rights reserved.
//

import UIKit

class PullUpMenuTransition: CustomAnimator {
    
    var isPresenting: Bool
    var isInteractive = false
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    public init(isPresenting: Bool, duration: TimeInterval = 2.35, interactionController: UIPercentDrivenInteractiveTransition? = nil) {
        self.interactionController = interactionController
        self.isPresenting = isPresenting
        super.init(duration: duration)
    }
    
    open override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else { return }
        let topVC = isPresenting ? toVC : fromVC
        let bottomVC = isPresenting ? fromVC : toVC
        let menuController = topVC as? PullUpMenuController
        let baseVC = bottomVC as? PullUpMenuButtonDelegate
        
        let containerView = transitionContext.containerView
        
        // precondition
        if isPresenting {
            containerView.addSubview(toVC.view)
            menuController?.view.layoutIfNeeded()
        }
        
        let finalBlurEffect = isPresenting ? menuController?.backgroundView.effect : nil
        if isPresenting {
            menuController?.backgroundView.effect = nil
        }
        
        
        // button preconditions
        
        let sourceButton = isPresenting ? baseVC?.pullUpMenuButton : menuController?.dismissButton
        let destinationButton = isPresenting ? menuController?.dismissButton : baseVC?.pullUpMenuButton
        let sourceButtonFrame = containerView.convert(sourceButton?.frame ?? .zero, from: sourceButton?.superview)
        let finalButtonFrame = containerView.convert(destinationButton?.frame ?? .zero, from: destinationButton?.superview)
        let dismissButtonFrame = isPresenting ? finalButtonFrame : sourceButtonFrame
        let openButtonFrame = isPresenting ? sourceButtonFrame : finalButtonFrame
        var transitionButton: AnimatablePullUpButton?
        if let button = sourceButton {
            let buttonFrame = containerView.convert(button.frame, from: button.superview)
            transitionButton = AnimatablePullUpButton(frame: buttonFrame, direction: isPresenting ? .up : .down)
            containerView.addSubview(transitionButton!)
            sourceButton?.alpha = 0
            destinationButton?.alpha = 0
        }
        
        // dismiss button inside menu controller
        let dismissButtonTransform = CGAffineTransform(scaleX: openButtonFrame.size.width/dismissButtonFrame.size.width, y: openButtonFrame.size.height/dismissButtonFrame.size.height).concatenating(CGAffineTransform(translationX: 0, y: (openButtonFrame.minY-dismissButtonFrame.minY)-(dismissButtonFrame.height-openButtonFrame.height)/2))
        menuController?.dismissButton.transform = isPresenting ? dismissButtonTransform : .identity
        menuController?.dismissButton.animate(toDirection: isPresenting ? .down : .up, duration: duration)
        menuController?.dismissButton.alpha = isPresenting ? 0 : 1
        
        // temporary button
        transitionButton?.animate(toDirection: self.isPresenting ? .down : .up, duration: self.duration, toFrame: finalButtonFrame)
        transitionButton?.animateTintColor(to: isPresenting ? .black : .white, duration: duration)
        transitionButton?.alpha = isPresenting ? 1 : 0
        
        #warning("fix for delay until button gets transparent (when settings alpha = 0)")
        baseVC?.pullUpMenuButton?.mask = isPresenting ? UIView() : nil
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            
            menuController?.backgroundView.effect = finalBlurEffect
            transitionButton?.frame = finalButtonFrame
            transitionButton?.alpha = self.isPresenting ? 0 : 1
            
            menuController?.dismissButton.transform = self.isPresenting ? .identity : dismissButtonTransform
            menuController?.dismissButton.alpha = self.isPresenting ? 1 : 0
            
        }) { (_) in
            destinationButton?.alpha = 1
            sourceButton?.alpha = 1
            menuController?.dismissButton.transform = .identity
            menuController?.dismissButton.animatedLayer.removeAllAnimations()
            menuController?.dismissButton.setDirection((self.isPresenting == transitionContext.transitionWasCancelled) ? .up : .down, animated: false)
            baseVC?.pullUpMenuButton?.mask = nil // removed later
            transitionButton?.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        
        // cell animation
        
        for cell in (menuController?.collectionView.visibleCells as? [PullUpMenuController.MenuItemCell]) ?? [] {
            let cellFrame = containerView.convert(cell.frame, from: cell.superview)
            //print(cellFrame.origin.y)
            
            let animationHeightFactor = self.duration / Double(containerView.frame.height) // start time per pixel higher
            let animationDuration: TimeInterval = 0.4*self.duration
            var animationStart: TimeInterval = animationHeightFactor * Double(containerView.frame.height-cellFrame.origin.y)
            if !self.isPresenting {
                animationStart = self.duration-animationStart-animationDuration
                animationStart = max(animationStart, 0)
            }
            
            let cellTransform = CGAffineTransform(translationX: 0, y: 30)
            
            // precondition
            cell.vibrancyView.contentView.alpha = self.isPresenting ? 0 : 1
            cell.imageView.alpha = self.isPresenting ? 0 : 1
            cell.titleLabel.alpha = self.isPresenting ? 0 : 1
            cell.subtitleLabel.alpha = self.isPresenting ? 0 : 1
            cell.transform = self.isPresenting ? cellTransform : .identity
            
            UIView.animateKeyframes(withDuration: self.duration, delay: 0, options: [], animations: {
                let relativeStart = animationStart / self.duration
                let relativeDuration = animationDuration / self.duration
                
                UIView.addKeyframe(withRelativeStartTime: relativeStart, relativeDuration: relativeDuration, animations: {
                    cell.vibrancyView.contentView.alpha = self.isPresenting ? 1 : 0
                    cell.imageView.alpha = self.isPresenting ? 1 : 0
                    cell.titleLabel.alpha = self.isPresenting ? 1 : 0
                    cell.subtitleLabel.alpha = self.isPresenting ? 1 : 0
                })
                
                UIView.addKeyframe(withRelativeStartTime: relativeStart + (self.isPresenting ? 0 : relativeDuration*0.8), relativeDuration: relativeDuration*0.2, animations: {
                    cell.transform = self.isPresenting ? .identity : cellTransform
                })
                
            }, completion: nil)
        }
 
    }
    
}

public protocol PullUpMenuButtonDelegate {
    var pullUpMenuButton: AnimatablePullUpButton? { get }
}
