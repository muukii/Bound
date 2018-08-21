//
//  BasicNavigationTransitionController.swift
//  Transition
//
//  Created by muukii on 8/20/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

public final class BasicNavigationTransitionController : NSObject, UIViewControllerAnimatedTransitioning {

  public enum Operation {
    case push
    case pop
  }

  public let operation: Operation

  public init(operation: Operation) {
    self.operation = operation
  }

  public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }

  public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    switch operation {
    case .push:

      let toVC = transitionContext.viewController(forKey: .to)!
      toVC.view.frame = transitionContext.finalFrame(for: toVC)
      let toView = transitionContext.view(forKey: .to)!

      toView.transform = .init(translationX: transitionContext.containerView.bounds.width, y: 0)

      transitionContext.containerView.addSubview(toView)

      UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        options: [],
        animations: {
          toVC.view.transform = .identity
      }, completion: { finish in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })

    case .pop:

      let toView = transitionContext.view(forKey: .to)!
      let fromView = transitionContext.view(forKey: .from)!

      transitionContext.containerView.insertSubview(toView, at: 0)

      UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        options: [],
        animations: {
          fromView.transform = .init(translationX: transitionContext.containerView.bounds.width, y: 0)
      }, completion: { finish in
        fromView.removeFromSuperview()
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })
    }
  }
}
