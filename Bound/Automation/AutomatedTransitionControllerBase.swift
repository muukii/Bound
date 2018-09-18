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

  public typealias TransitionGroupFactory = (_ context: UIViewControllerContextTransitioning) throws -> TransitionGroup

  let setupAnimation: (Animator, NotifyTransitionCompleted) -> Void
  let fallbackTransitionController: UIViewControllerAnimatedTransitioning

  public init(
    fallbackTransitionController: UIViewControllerAnimatedTransitioning,
    setupAnimation: @escaping (Animator, NotifyTransitionCompleted) -> Void
    ) {

    self.fallbackTransitionController = fallbackTransitionController
    self.setupAnimation = setupAnimation
  }

}
