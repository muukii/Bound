//
//  IsolatedTransition.swift
//  Transition
//
//  Created by muukii on 8/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

@available(iOS 10, *)
public struct IsolatedTransition {

  // MARK: - Properties

  public let targets: [UIView]

  public let animations: [IsolatedAnimating]

  public let afterProcessTiming: AfterProcessTiming

  public let delay: TimeInterval

  private let animatorOptions: PropertyAnimatorBuilder

  public var estimatedTotalDuration: TimeInterval {
    return delay + animatorOptions.duration
  }

  // MARK: - Initializers

  ///
  ///
  /// - Parameters:
  ///   - targets:
  ///   - animations:
  ///   - delay:
  ///   - animatorOptions:
  ///   - afterProcessTiming: 
  public init(
    targets: UIView?...,
    animations: [IsolatedAnimating],
    delay: TimeInterval = 0,
    animatorOptions: PropertyAnimatorBuilder,
    afterProcessTiming: AfterProcessTiming = .whenAllAnimationsFinished
    ) {

    self.targets = targets.compactMap { $0 }
    self.animations = animations
    self.delay = delay
    self.animatorOptions = animatorOptions
    self.afterProcessTiming = afterProcessTiming
  }

  public init(
    targets: [UIView?],
    animations: [IsolatedAnimating],
    delay: TimeInterval = 0,
    animatorOptions: PropertyAnimatorBuilder,
    afterProcessTiming: AfterProcessTiming = .whenAllAnimationsFinished
    ) {
    self.targets = targets.compactMap { $0 }
    self.animations = animations
    self.delay = delay
    self.animatorOptions = animatorOptions
    self.afterProcessTiming = afterProcessTiming
  }

  // MARK: - Functions

  func applyBeforeProcess() {

    animations.forEach {
      for target in targets {
        $0.apply(to: target, in: .before)
      }
    }

  }

  func run() -> UIViewPropertyAnimator? {

    let animator = animatorOptions.build()

    animator.addAnimations {
      self.animations.forEach {
        for target in self.targets {
          $0.apply(to: target, in: .main)
        }
      }
    }

    if case .whenAnimationFinished = afterProcessTiming {
      animator.addCompletion { _ in
        self._applyAfterProcess()
      }
    }

    animator.startAnimation(afterDelay: delay)

    return animator
  }

  func applyAfterProcess() {

    guard case .whenAllAnimationsFinished = afterProcessTiming else {
      return
    }

    _applyAfterProcess()
  }

  @inline(__always)
  private func _applyAfterProcess() {
    self.animations.forEach {
      for target in self.targets {
        $0.apply(to: target, in: .after)
      }
    }
  }
}
