//
//  AutomatedPopTransitionController.swift
//  Transition
//
//  Created by muukii on 8/15/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

@available(iOS 10, *)
public final class AutomatedPopTransitionController : AutomatedTransitionControllerBase, UIViewControllerAnimatedTransitioning {

  public override init(
    fallbackTransitionController: UIViewControllerAnimatedTransitioning = BasicNavigationTransitionController(operation: .pop),
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

    let containerView = transitionContext.containerView

    guard
      let fromView = transitionContext.view(forKey: .from),
      let toView = transitionContext.view(forKey: .to) else {
        preconditionFailure("Something went wrong on UIKit")
    }

    DispatchQueue.main.async {

      containerView.insertSubview(toView, belowSubview: fromView)

      let animator = Animator()

      let container = Container.init(
        animator: animator,
        transitionContext: transitionContext,
        completion: {
          transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })

      self.setupAnimation(container)

      animator.addErrorHandler { (error) in
        self.fallbackTransitionController.animateTransition(using: transitionContext)
      }

      animator.run(in: transitionContext.containerView)
    }

  }

}
