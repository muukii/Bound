//
//  MatchedTransition.swift
//  Transition
//
//  Created by muukii on 8/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

@available(iOS 10, *)
public final class MatchedTransition {

  public let animation: MatchedAnimating

  public let afterProcessTiming: AfterProcessTiming

  public let delay: TimeInterval

  private let context: MatchedAnimationContext

  private let animatorOptions: PropertyAnimatorBuilder

  public var estimatedTotalDuration: TimeInterval {
    return delay + animatorOptions.duration
  }

  ///
  ///
  /// - Parameters:
  ///   - sourceView:
  ///   - targetView:
  ///   - delay:
  ///   - animation:
  ///   - animatorOptions:
  ///   - afterProcessTiming:
  ///   - containerView:
  public init(
    source: UIView,
    target: UIView,
    delay: TimeInterval = 0,
    animation: MatchedAnimating,
    animatorOptions: PropertyAnimatorBuilder,
    afterProcessTiming: AfterProcessTiming = .whenAllAnimationsFinished,
    in containerView: UIView
    ) {

    self.delay = delay
    self.animatorOptions = animatorOptions
    self.animation = animation
    self.afterProcessTiming = afterProcessTiming

    self.context = MatchedAnimationContext(
      sourceView: source,
      targetView: target,
      in: containerView
    )

  }

  func applyBeforeProcess() {
    context.updateFramesInContainer()
    animation.apply(to: context, in: .before)
  }

  func run() -> UIViewPropertyAnimator {

    let animator = animatorOptions.build()

    animator.addAnimations {
      self.animation.apply(to: self.context, in: .main)
    }

    if case .whenAnimationFinished = afterProcessTiming {
      animator.addCompletion { _ in
        self.animation.apply(to: self.context, in: .after)
      }
    }

    animator.startAnimation(afterDelay: delay)

    return animator

  }

  func applyAfterProcess() {

    if case .whenAllAnimationsFinished = afterProcessTiming {
      animation.apply(to: context, in: .after)
    }
  }
}
