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
    transitionGroupFactory: @escaping TransitionGroupFactory,
    alongsideTransitionGroupFactory: TransitionGroupFactory? = nil
    ) {

    super.init(
      fallbackTransitionController: fallbackTransitionController,
      transitionGroupFactory: transitionGroupFactory,
      alongsideTransitionGroupFactory: alongsideTransitionGroupFactory
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

    let animator = Animator(
      preProcess: [
        .init {
          containerView.insertSubview(toView, belowSubview: fromView)
        }
      ],
      postProcess: []
    )

    if let alongsideTransitionGroupFactory = alongsideTransitionGroupFactory {
      animator.add(
        transitionGroupFactory: {
          try alongsideTransitionGroupFactory(transitionContext)
      },
        completion: {})
    }

    animator.add(
      transitionGroupFactory: {
        try self.transitionGroupFactory(transitionContext)
    }) {
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }

    animator.addErrorHandler { (error) in
      self.fallbackTransitionController.animateTransition(using: transitionContext)
    }

    animator.run(in: transitionContext)

  }

}
