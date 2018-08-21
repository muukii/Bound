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

  public typealias TransitionGroupFactory = (_ context: UIViewControllerContextTransitioning) throws -> TransitionGroup

  let transitionGroupFactory: TransitionGroupFactory
  let alongsideTransitionGroupFactory: TransitionGroupFactory?
  let fallbackTransitionController: UIViewControllerAnimatedTransitioning

  public init(
    fallbackTransitionController: UIViewControllerAnimatedTransitioning,
    transitionGroupFactory: @escaping TransitionGroupFactory,
    alongsideTransitionGroupFactory: TransitionGroupFactory? = nil
    ) {

    self.fallbackTransitionController = fallbackTransitionController
    self.transitionGroupFactory = transitionGroupFactory
    self.alongsideTransitionGroupFactory = alongsideTransitionGroupFactory
  }

}
