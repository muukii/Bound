//
//  AutomatedTransitionControllerBase.swift
//  Transition
//
//  Created by muukii on 8/15/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

@available(iOS 10, *)
open class AutomatedTransitionControllerBase : NSObject {

  public typealias NotifyTransitionCompleted = () -> Void

  public struct Container {

    public let animator: Animator
    public let transitionContext: UIViewControllerContextTransitioning
    private let _completion: NotifyTransitionCompleted

    init(animator: Animator, transitionContext: UIViewControllerContextTransitioning, completion: @escaping NotifyTransitionCompleted) {

      self.animator = animator
      self.transitionContext = transitionContext
      self._completion = completion
    }

    public func notifyTransitionCompleted() {
      _completion()
    }
  }

  public typealias SetupAnimation = (Container) -> Void

  let setupAnimation: SetupAnimation
  let fallbackTransitionController: UIViewControllerAnimatedTransitioning

  public init(
    fallbackTransitionController: UIViewControllerAnimatedTransitioning,
    setupAnimation: @escaping SetupAnimation
    ) {

    self.fallbackTransitionController = fallbackTransitionController
    self.setupAnimation = setupAnimation
  }

}
