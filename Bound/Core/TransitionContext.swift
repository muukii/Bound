//
//  TransitionContext.swift
//  Bound
//
//  Created by muukii on 9/19/18.
//

import Foundation

@available(iOS 10, *)
public struct AnimatorSet {
  let coldAnimator: UIViewPropertyAnimator
  let delay: TimeInterval

  init(coldAnimator: UIViewPropertyAnimator, delay: TimeInterval) {
    self.coldAnimator = coldAnimator
    self.delay = delay
  }
}

@available(iOS 10, *)
public protocol Animating {

  func preProcess()
  func make() -> AnimatorSet
  func postProcess()
}

@available(iOS 10.0, *)
public final class TransitionGroup {
  var animations: [Animating] = []

  public func add(animation: Animating) {
    animations.append(animation)
  }

  public func add(animation: () throws -> Animating) rethrows {
    animations.append(try animation())
  }
}

@available(iOS 10.0, *)
public final class TransitionContext {

  public let containerView: UIView

  init(containerView: UIView) {
    self.containerView = containerView
  }

  public func makeSnapshot<T: UIView, S: UIView>(
    from: T,
    render: (SnapshotSource<T>) -> S
    ) -> S {

    let source = SnapshotSource<T>(source: from)
    let view = render(source)
    //    let center = from.convert(from.center, to: containerView)
    //    view.center = center

    return view
  }

  public func makePath(to: UIView, from: UIView) -> MatchedAnimations.MovePath {

    let fromFrame = from.convert(from.bounds, to: containerView)
    let toFrame = to.convert(to.bounds, to: containerView)

    return .init(
      fromView: from,
      toView: to,
      fromFrame: fromFrame,
      toFrame: toFrame
    )
  }
}

