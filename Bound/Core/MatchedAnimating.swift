//
//  MatchedAnimation.swift
//  Transition
//
//  Created by muukii on 7/18/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

public protocol MatchedAnimating {
  func apply(to context: MatchedAnimationContext, in step: TransitionStep)
}

@available(iOS 10, *)
public enum MatchedAnimations {

  public final class Crossfade : MatchedAnimating {

    private weak var sourceSnapshotView: UIView?
    private weak var targetSnapshotView: UIView?

    private let sourceSnapshot: Snapshot
    private let targetSnapshot: Snapshot

    public init(sourceSnapshot: Snapshot, targetSnapshot: Snapshot) {
      self.sourceSnapshot = sourceSnapshot
      self.targetSnapshot = targetSnapshot
    }

    public func apply(to context: MatchedAnimationContext, in step: TransitionStep) {

      switch step {
      case .before:

        let _sourceSnapshotView = sourceSnapshot.build()
        let _targetSnapshotView = targetSnapshot.build()

        context.sourceView.alpha = 0
        context.targetView.alpha = 1

        context.containerView.addSubview(_sourceSnapshotView)
        context.containerView.addSubview(_targetSnapshotView)

        sourceSnapshotView = _sourceSnapshotView
        targetSnapshotView = _targetSnapshotView

        _sourceSnapshotView.frame = context.frameForSourceViewInContainer
        _targetSnapshotView.frame = context.frameForTargetViewInContainer
        _targetSnapshotView.transform = TransitionUtils.makeCGAffineTransform(
          from: context.frameForTargetViewInContainer,
          to: context.frameForSourceViewInContainer
        )
        _targetSnapshotView.alpha = 0

      case .main:

        sourceSnapshotView?.transform = TransitionUtils.makeCGAffineTransform(
          from: context.frameForSourceViewInContainer,
          to: context.frameForTargetViewInContainer
        )
        targetSnapshotView?.transform = .identity

        sourceSnapshotView?.alpha = 0
        targetSnapshotView?.alpha = 1

      case .after:

        sourceSnapshotView?.removeFromSuperview()
        targetSnapshotView?.removeFromSuperview()

        context.sourceView.alpha = 1
        context.targetView.alpha = 1
      }

    }
  }

  public final class MoveFromSource : MatchedAnimating {

    private weak var snapshotView: UIView?

    private let sourceSnapshot: Snapshot

    public init(sourceSnapshot: Snapshot) {
      self.sourceSnapshot = sourceSnapshot
    }

    public func apply(to context: MatchedAnimationContext, in step: TransitionStep) {

      switch step {
      case .before:

        let snapshotView = sourceSnapshot.build()

        context.sourceView.alpha = 0
        context.targetView.alpha = 0

        self.snapshotView = snapshotView

        snapshotView.frame = context.frameForSourceViewInContainer

        context.containerView.addSubview(snapshotView)

      case .main:

        self.snapshotView?.frame = context.frameForTargetViewInContainer

      case .after:

        self.snapshotView?.removeFromSuperview()

        context.sourceView.alpha = 1
        context.targetView.alpha = 1
      }
    }
  }
}
