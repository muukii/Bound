//
//  MatchedAnimation.swift
//  Transition
//
//  Created by muukii on 7/18/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

@available(iOS 10, *)
public enum MatchedAnimations {

  public struct MovePath {

    public let fromView: UIView
    public let toView: UIView

    public let fromFrame: CGRect
    public let toFrame: CGRect
  }

  public final class Crossfade : Animating {

    public let sourceSnapshot: UIView
    public let targetSnapshot: UIView
    public let parameter: AnimatonParameter
    public let containerView: UIView
    public let path: MovePath
    public let removeOnCompletion: Bool
    public let delay: TimeInterval

    public init(
      sourceSnapshot: UIView,
      targetSnapshot: UIView,
      path: MovePath,
      parameter: AnimatonParameter,
      delay: TimeInterval = 0,
      containerView: UIView,
      removeOnCompletion: Bool = false
      ) {

      self.sourceSnapshot = sourceSnapshot
      self.targetSnapshot = targetSnapshot
      self.containerView = containerView
      self.path = path
      self.delay = delay
      self.parameter = parameter
      self.removeOnCompletion = removeOnCompletion
    }

    public func preProcess() {
      path.fromView.alpha = 0
      path.toView.alpha = 0
      containerView.addSubview(sourceSnapshot)
      containerView.addSubview(targetSnapshot)
      sourceSnapshot.frame = path.fromFrame
      targetSnapshot.frame = path.fromFrame

      self.sourceSnapshot.alpha = 1
      self.targetSnapshot.alpha = 0
    }

    public func make() -> AnimatorSet {

      let animator = parameter.build()
      animator.addAnimations {

        self.sourceSnapshot.alpha = 0
        self.targetSnapshot.alpha = 1

        self.sourceSnapshot.transform = TransitionUtils.makeCGAffineTransform(
          from: self.path.fromFrame,
          to: self.path.toFrame
        )

        self.targetSnapshot.transform = TransitionUtils.makeCGAffineTransform(
          from: self.path.fromFrame,
          to: self.path.toFrame
        )

      }
      if removeOnCompletion {
        animator.addCompletion { _ in
          self.path.fromView.alpha = 1
          self.path.toView.alpha = 1
          self.sourceSnapshot.removeFromSuperview()
          self.targetSnapshot.removeFromSuperview()
        }
      }

      return AnimatorSet(coldAnimator: animator, delay: delay)
    }

    public func postProcess() {
      if !removeOnCompletion {
        path.fromView.alpha = 1
        path.toView.alpha = 1
        sourceSnapshot.removeFromSuperview()
        targetSnapshot.removeFromSuperview()
      }
    }
  }

  public final class MoveSnapshot : Animating {

    public let snapshot: UIView
    public let parameter: AnimatonParameter
    public let containerView: UIView
    public let path: MovePath
    public let removeOnCompletion: Bool
    public let delay: TimeInterval

    public init(
      snapshot: UIView,
      path: MovePath,
      parameter: AnimatonParameter,
      delay: TimeInterval = 0,
      containerView: UIView,
      removeOnCompletion: Bool = false
      ) {

      self.snapshot = snapshot
      self.containerView = containerView
      self.path = path
      self.delay = delay
      self.parameter = parameter
      self.removeOnCompletion = removeOnCompletion
    }

    public func preProcess() {
      path.fromView.alpha = 0
      path.toView.alpha = 0
      containerView.addSubview(snapshot)
      snapshot.frame = path.fromFrame
    }

    public func make() -> AnimatorSet {

      let animator = parameter.build()
      animator.addAnimations {
        self.snapshot.transform = TransitionUtils.makeCGAffineTransform(
          from: self.path.fromFrame,
          to: self.path.toFrame
        )
      }
      if removeOnCompletion {
        animator.addCompletion { _ in
          self.path.fromView.alpha = 1
          self.path.toView.alpha = 1
          self.snapshot.removeFromSuperview()
        }
      }

      return AnimatorSet(coldAnimator: animator, delay: delay)
    }

    public func postProcess() {
      if !removeOnCompletion {
        self.path.fromView.alpha = 1
        self.path.toView.alpha = 1
        snapshot.removeFromSuperview()
      }
    }
  }
}
