//
//  BasicModalPresentationTransitionController.swift
//  Transition
//
//  Created by muukii on 8/20/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

public final class BasicModalPresentationTransitionController : NSObject, UIViewControllerAnimatedTransitioning {

  public enum Operation {
    case presentation
    case dismissable
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
    case .presentation:

      let toVC = transitionContext.viewController(forKey: .to)!
      toVC.view.frame = transitionContext.finalFrame(for: toVC)
      let toView = transitionContext.view(forKey: .to)!

      toView.transform = .init(translationX: 0, y: transitionContext.containerView.bounds.height)

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

    case .dismissable:

      let fromView = transitionContext.view(forKey: .from)!

      UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        options: [],
        animations: {
          fromView.transform = .init(translationX: 0, y: transitionContext.containerView.bounds.height)
      }, completion: { finish in
        fromView.removeFromSuperview()
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      })
    }
  }
}
