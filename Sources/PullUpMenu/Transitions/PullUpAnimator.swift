//
//  PullUpAnimator.swift
//  
//
//  Created by Alexander Eichhorn on 06.10.19.
//

import UIKit

public class PullUpAnimator {
    
    enum State {
        case opened
        case closed
        
        var opposite: State {
            switch self {
            case .opened: return .closed
            case .closed: return .opened
            }
        }
    }
    
    private var animator = UIViewPropertyAnimator()
    private var displayLink: CADisplayLink?
    
    private var creationFinishedHandler: (() -> Void)?
    
    private(set) var state: State = .closed
    
    weak var menuController: PullUpMenuController?
    
    init(menuController: PullUpMenuController) {
        self.menuController = menuController
        setupDisplayLink()
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    public func open() {
        createAnimation()
        
        animator.startAnimation()
        displayLink?.isPaused = false
    }
    
    public func close() {
        createAnimation()
        
        animator.startAnimation()
        displayLink?.isPaused = false
    }
    
    func updateInteractive(percentComplete: CGFloat) {
        guard menuController?.modalPresentationStyle != .popover else { return }
        let percentComplete = max(min(percentComplete, 1), 0)
        animator.fractionComplete = percentComplete
        containerLayers.forEach({ $0.timeOffset = CFTimeInterval(percentComplete) })
    }
    
    func cancel(animated: Bool = true) {
        if animator.state != .inactive {
            if animated {
                self.animator.isReversed = true
                let timingParameters: UITimingCurveProvider = self.state == .opened ? UICubicTimingParameters(animationCurve: .linear) : UISpringTimingParameters(damping: 1, response: 0.4) // spring timing messes up blur background when opened
                let preferredDuration = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters).duration
                self.animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: self.animator.fractionComplete * CGFloat(preferredDuration / self.animator.duration))
                self.displayLink?.isPaused = false
            } else {
                self.animator.stopAnimation(false)
                self.animator.finishAnimation(at: .start)
            }
        } else {
            creationFinishedHandler = {
                self.animator.stopAnimation(true)
                self.displayLink?.isPaused = true
            }
        }
    }
    
    func finish(relativeVelocity: CGFloat) {
        let timingParameters = UISpringTimingParameters(damping: 0.8, response: 0.3, initialVelocity: CGVector(dx: 0, dy: relativeVelocity))
        let preferredDuration = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters).duration
        if animator.state != .inactive {
            animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: CGFloat(preferredDuration / animator.duration))
            displayLink?.isPaused = false
        } else {
            creationFinishedHandler = {
                self.animator.startAnimation()
                self.displayLink?.isPaused = false
            }
        }
        
    }
    
    var isRunning: Bool {
        animator.isRunning
    }
    
    var currentFractionComplete: CGFloat {
        animator.isReversed ? (1 - animator.fractionComplete) : animator.fractionComplete
    }
    
    
    /// - parameter preloadDestination: first loads destination (menu controller) asynchronously before creating animation
    func createAnimation(preloadDestination: Bool = false) {
        if animator.isRunning {
            animator.pauseAnimation()
            animator.isReversed = false
            displayLink?.isPaused = false
            return
        }
        
        guard let menuController = menuController,
            let bottomVC = menuController.parent else { return }
        
        let baseVC = bottomVC as? PullUpMenuButtonDelegate
        
        // load menu controller first asynchronously (to make sure all cells are loaded) before creating animation
        if preloadDestination {
            menuController.view.alpha = 0
            menuController.collectionView.preloadCells {
                menuController.view.alpha = 1
                self.createAnimation()
            }
            return
        }
        
        // precondition
        if state == .closed {
            menuController.view.layoutIfNeeded()
        }
        
        let finalBlurEffect = state == .closed ? menuController.backgroundView.effect : nil
        if state == .closed {
            menuController.backgroundView.effect = nil
        }
        
        
        // button preconditions
        
        let midBottomFrame = CGRect(x: bottomVC.view.frame.midX, y: bottomVC.view.frame.maxY, width: 20, height: 20) // used as backup
        let sourceButton = state == .closed ? baseVC?.pullUpMenuButton : menuController.dismissButton
        let destinationButton = state == .closed ? menuController.dismissButton : baseVC?.pullUpMenuButton
        let sourceButtonFrame = (menuController.view.convert(sourceButton?.frame, from: sourceButton?.superview)) ?? midBottomFrame
        let finalButtonFrame = (menuController.view.convert(destinationButton?.frame, from: destinationButton?.superview)) ?? midBottomFrame
        let dismissButtonFrame = state == .closed ? finalButtonFrame : sourceButtonFrame
        let openButtonFrame = state == .closed ? sourceButtonFrame : finalButtonFrame
        var transitionButton: AnimatablePullUpButton?
        if let button = sourceButton, destinationButton != nil {
            let buttonFrame = menuController.view.convert(button.frame, from: button.superview)
            transitionButton = AnimatablePullUpButton(frame: buttonFrame, direction: state == .closed ? .up : .down)
            menuController.view.addSubview(transitionButton!)
            sourceButton?.alpha = 0
            destinationButton?.alpha = 0
        }
        
        // dismiss button inside menu controller
        let dismissButtonTransform = CGAffineTransform(scaleX: openButtonFrame.size.width/dismissButtonFrame.size.width, y: openButtonFrame.size.height/dismissButtonFrame.size.height).concatenating(CGAffineTransform(translationX: 0, y: (openButtonFrame.minY-dismissButtonFrame.minY)-(dismissButtonFrame.height-openButtonFrame.height)/2))
        menuController.dismissButton.transform = state == .closed ? dismissButtonTransform : .identity
        menuController.dismissButton.animate(toDirection: state == .closed ? .down : .up, duration: 1.0)
        menuController.dismissButton.alpha = state == .closed ? 0 : 1
        
        // temporary button
        transitionButton?.animate(toDirection: state == .closed ? .down : .up, duration: 1.0, toFrame: finalButtonFrame)
        transitionButton?.animateTintColor(to: state == .closed ? .black : .white, duration: 1.0)
        transitionButton?.alpha = state == .closed ? 1 : 0
        
        #warning("fix for delay until button gets transparent (when settings alpha = 0)")
        baseVC?.pullUpMenuButton?.mask = state == .closed ? UIView() : nil
        
        
        // pause all animated layers
        containerLayers.forEach({
            $0.speed = 0
            $0.timeOffset = 0
        })
        
        
        let timingParameters = UISpringTimingParameters(damping: 1, response: 0.4)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator.addAnimations {
            menuController.backgroundView.effect = finalBlurEffect
            transitionButton?.frame = finalButtonFrame
            transitionButton?.alpha = self.state == .closed ? 0 : 1
            
            menuController.dismissButton.transform = self.state == .closed ? .identity : dismissButtonTransform
            menuController.dismissButton.alpha = self.state == .closed ? 1 : 0
        }
        
        // cell animation
        for cell in (menuController.collectionView.visibleCells as? [PullUpMenuController.MenuItemCell]) ?? [] {
            let cellFrame = menuController.view.convert(cell.frame, from: cell.superview)
            //print(cellFrame.origin.y)
            let duration = 1.0
            
            let animationHeightFactor = duration / Double(menuController.view.frame.height) // start time per pixel higher
            let animationDuration: TimeInterval = 0.4*duration
            var animationStart: TimeInterval = animationHeightFactor * Double(menuController.view.frame.height-cellFrame.origin.y)
            if self.state == .opened {
                animationStart = duration-animationStart-animationDuration
                animationStart = max(animationStart, 0)
            }
            
            let cellTransform = CGAffineTransform(translationX: 0, y: 30)
            
            // precondition
            cell.vibrancyView.contentView.alpha = self.state == .closed ? 0 : 1
            cell.imageView.alpha = self.state == .closed ? 0 : 1
            cell.titleLabel.alpha = self.state == .closed ? 0 : 1
            cell.subtitleLabel.alpha = self.state == .closed ? 0 : 1
            cell.transform = self.state == .closed ? cellTransform : .identity
            
            animator.addAnimations {
                UIView.animateKeyframes(withDuration: 0, delay: 0, options: [], animations: {
                    let relativeStart = animationStart / duration
                    let relativeDuration = animationDuration / duration
                    
                    UIView.addKeyframe(withRelativeStartTime: relativeStart, relativeDuration: relativeDuration, animations: {
                        cell.vibrancyView.contentView.alpha = self.state == .closed ? 1 : 0
                        cell.imageView.alpha = self.state == .closed ? 1 : 0
                        cell.titleLabel.alpha = self.state == .closed ? 1 : 0
                        cell.subtitleLabel.alpha = self.state == .closed ? 1 : 0
                    })
                    
                    UIView.addKeyframe(withRelativeStartTime: relativeStart + (self.state == .closed ? 0 : relativeDuration*0.8), relativeDuration: relativeDuration*0.2, animations: {
                        cell.transform = self.state == .closed ? .identity : cellTransform
                    })
                    
                }, completion: nil)
            }
        }
        
        
        animator.addCompletion { position in
        
            self.animationFinished(position: position)
            
            destinationButton?.alpha = 1
            sourceButton?.alpha = 1
            menuController.dismissButton.transform = .identity
            menuController.dismissButton.animatedLayer.removeAllAnimations()
            menuController.dismissButton.setDirection((self.state == .closed) ? .up : .down, animated: false)
            baseVC?.pullUpMenuButton?.mask = nil // removed later
            transitionButton?.removeFromSuperview()
        }
        
        creationFinishedHandler?()
        creationFinishedHandler = nil
    }
    
    private func animationFinished(position: UIViewAnimatingPosition) {
        
        if position == .end {
            state = state.opposite
        }
        
        displayLink?.isPaused = true
        
        if state == .closed {
            menuController?.view.removeFromSuperview()
            menuController?.removeFromParent()
            displayLink?.invalidate()
        }
    }
    
    
    /// layers with interactive CAAnimations
    private var containerLayers: [CALayer] {
        guard let menuController = menuController else { return [] }
        
        var layers = menuController.view.subviews.compactMap({ ($0 as? AnimatablePullUpButton)?.animatedLayer })
        
        layers += [menuController.dismissButton.animatedLayer]
        
        return layers
    }
    
    
    // MARK: - Display Link
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.isPaused = true
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func update(displayLink: CADisplayLink) {
        //print("\(animator.fractionComplete) \t \(animator.isRunning) \t (\(displayLink.timestamp))")
        
        if animator.isRunning {
            let percentComplete = animator.isReversed ? (1 - animator.fractionComplete) : animator.fractionComplete
            containerLayers.forEach({ $0.timeOffset = CFTimeInterval(percentComplete) })
        }
    }
}


public protocol PullUpMenuButtonDelegate {
    var pullUpMenuButton: AnimatablePullUpButton? { get }
}
