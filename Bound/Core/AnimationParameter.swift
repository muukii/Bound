//
//  PropertyAnimatorBuilder.swift
//  Bound
//
//  Created by muukii on 7/11/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

@available(iOS 10, *)
public struct AnimationParameter {

  let duration: TimeInterval

  private let _build: () -> UIViewPropertyAnimator

  public init(duration: TimeInterval, timingParameters parameters: UITimingCurveProvider) {

    self.duration = duration

    self._build = {
      UIViewPropertyAnimator(duration: duration, timingParameters: parameters)
    }
  }

  public init(duration: TimeInterval, curve: UIView.AnimationCurve) {

    self.duration = duration

    self._build = {
      UIViewPropertyAnimator(duration: duration, curve: curve)
    }
  }

  public init(duration: TimeInterval, controlPoint1 point1: CGPoint, controlPoint2 point2: CGPoint) {

    self.duration = duration

    self._build = {
      UIViewPropertyAnimator(duration: duration, controlPoint1: point1, controlPoint2: point2)
    }
  }

  public init(duration: TimeInterval, dampingRatio ratio: CGFloat) {

    self.duration = duration

    self._build = {
      UIViewPropertyAnimator(duration: duration, dampingRatio: ratio)
    }
  }

  public func build() -> UIViewPropertyAnimator {
    let animator = _build()
    animator.isUserInteractionEnabled = true
    return animator
  }
}

@available(iOS 10, *)
extension AnimationParameter {

  public static let immediately: AnimationParameter = .init(duration: 0, curve: .linear)
}
