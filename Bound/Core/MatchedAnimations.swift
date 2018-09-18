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

//  public final class Crossfade : Animating {
//
//    private weak var sourceSnapshotView: UIView?
//    private weak var targetSnapshotView: UIView?
//
//    private let sourceSnapshot: Snapshot
//    private let targetSnapshot: Snapshot
//
//    public init() {
//      self.sourceSnapshot = sourceSnapshot
//      self.targetSnapshot = targetSnapshot
//    }
//
//    public func apply(to context: MatchedAnimationContext, in step: TransitionStep) {
//
//      switch step {
//      case .before:
//
//        let _sourceSnapshotView = sourceSnapshot.build()
//        let _targetSnapshotView = targetSnapshot.build()
//
//        context.sourceView.alpha = 0
//        context.targetView.alpha = 0
//
//        context.containerView.addSubview(_sourceSnapshotView)
//        context.containerView.addSubview(_targetSnapshotView)
//
//        sourceSnapshotView = _sourceSnapshotView
//        targetSnapshotView = _targetSnapshotView
//
//        _sourceSnapshotView.frame = context.frameForSourceViewInContainer
//        _targetSnapshotView.frame = context.frameForTargetViewInContainer
//        _targetSnapshotView.transform = TransitionUtils.makeCGAffineTransform(
//          from: context.frameForTargetViewInContainer,
//          to: context.frameForSourceViewInContainer
//        )
//        _targetSnapshotView.alpha = 0
//
//      case .main:
//
//        sourceSnapshotView?.transform = TransitionUtils.makeCGAffineTransform(
//          from: context.frameForSourceViewInContainer,
//          to: context.frameForTargetViewInContainer
//        )
//        targetSnapshotView?.transform = .identity
//
//        sourceSnapshotView?.alpha = 0
//        targetSnapshotView?.alpha = 1
//
//      case .after:
//
//        sourceSnapshotView?.removeFromSuperview()
//        targetSnapshotView?.removeFromSuperview()
//
//        context.sourceView.alpha = 1
//        context.targetView.alpha = 1
//      }
//
//    }
//  }

  public struct MovePath {

    public let fromView: UIView
    public let toView: UIView

    public let fromFrame: CGRect
    public let toFrame: CGRect
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
       self.snapshot.frame = self.path.toFrame
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
