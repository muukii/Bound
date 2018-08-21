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
    
    guard
      let toViewController = transitionContext.viewController(forKey: .to) else {
        preconditionFailure("Something went wrong on UIKit")
    }

    let animator = Animator(
      preProcess: [
        .init {
          toViewController.beginAppearanceTransition(true, animated: true)
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
      toViewController.endAppearanceTransition()
    }

    animator.addErrorHandler { (error) in
      self.fallbackTransitionController.animateTransition(using: transitionContext)
    }

    animator.run(in: transitionContext)

  }

}
