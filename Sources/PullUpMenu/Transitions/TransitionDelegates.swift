//
//  TransitionDelegates.swift
//  MusicPullUpMenuTest
//
//  Created by Alexander Eichhorn on 27.07.19.
//  Copyright © 2019 Losjet - Alexander Eichhorn. All rights reserved.
//

import UIKit

extension PullUpMenuController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PullUpMenuTransition(isPresenting: true, interactionController: (presenting as? InteractiveTransitionParent)?.interactiveController) // TODO: maybe get interactive controller differently
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PullUpMenuTransition(isPresenting: false, interactionController: interactionController)
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? PullUpMenuTransition,
            let interactionController = animator.interactionController as? PullUpMenuInteractionController,
            interactionController.inProgress else { return nil }
        animator.isInteractive = true
        return interactionController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? PullUpMenuTransition,
            let interactionController = animator.interactionController as? PullUpMenuInteractionController,
            interactionController.inProgress else { return nil }
        animator.isInteractive = true
        return interactionController
    }
}


protocol InteractiveTransitionParent: UIViewController {
    var interactiveController: PullUpMenuInteractionController? { get }
}
