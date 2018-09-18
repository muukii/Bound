//
//  AutomatedDismissalTransitionController.swift
//  Transition
//
//  Created by muukii on 8/15/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

@available(iOS 10, *)
public final class AutomatedDismissalTransitionController : AutomatedTransitionControllerBase, UIViewControllerAnimatedTransitioning {

  public override init(
    fallbackTransitionController: UIViewControllerAnimatedTransitioning = BasicModalPresentationTransitionController(operation: .dismissable),
    setupAnimation: @escaping SetupAnimation
    ) {

    super.init(
      fallbackTransitionController: fallbackTransitionController,
      setupAnimation: setupAnimation
      )
  }

  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0
  }

  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    guard
      let toViewController = transitionContext.viewController(forKey: .to) else {
        preconditionFailure("Something went wrong on UIKit")
    }

    toViewController.beginAppearanceTransition(true, animated: true)

    let animator = Animator()

    let container = Container.init(
      animator: animator,
      transitionContext: transitionContext,
      completion: {
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        toViewController.endAppearanceTransition()
    })

    setupAnimation(container)

    animator.addErrorHandler { (error) in
      self.fallbackTransitionController.animateTransition(using: transitionContext)
    }

    animator.run(in: transitionContext.containerView)

  }

}
