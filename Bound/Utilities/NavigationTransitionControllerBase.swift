//
//  NavigationTransitionControllerBase.swift
//  Transition
//
//  Created by muukii on 8/15/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

open class NavigationTransitionControllerBase : NSObject, UIViewControllerAnimatedTransitioning {

  public let operation: UINavigationControllerOperation

  public init(operation: UINavigationControllerOperation) {
    self.operation = operation
    super.init()
  }

  open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    fatalError("Needs override")
  }

  open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    fatalError("Needs override")
  }
}
