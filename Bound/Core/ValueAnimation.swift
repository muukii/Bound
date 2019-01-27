//
//  Default.swift
//  Transition
//
//  Created by muukii on 7/11/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

@available(iOS 10, *)
public struct ValueAnimation<T : UIView> : Animating {

  public struct ChangeSet<T : UIView> {

    private let _pre: (T) -> Void
    private let _apply: (T) -> Void
    private let _post: (T) -> Void

    public init<S>(
      target: ReferenceWritableKeyPath<T, S>,
      pre: @escaping @autoclosure () -> S? = nil,
      to: @escaping @autoclosure () -> S,
      post: @escaping @autoclosure () -> S? = nil
      ) {

      self._pre = { view in
        if let pre = pre() {
          view[keyPath: target] = pre
        }
      }

      self._apply = { view in
        view[keyPath: target] = to()
      }

      self._post = { view in
        if let post = post() {
          view[keyPath: target] = post
        }
      }

    }

    func preProcess(target: T) {
      _pre(target)
    }

    func apply(target: T) {
      _apply(target)
    }

    func postProcess(target: T) {
      _post(target)
    }
  }

  public let targets: [T]
  public let changes: [ChangeSet<T>]
  public let parameter: AnimationParameter
  public let delay: TimeInterval

  public init(
    targets: [T?],
    changes: [ChangeSet<T>],
    parameter: AnimationParameter,
    delay: TimeInterval = 0
    ) {
    self.targets = targets.compactMap { $0 }
    self.changes = changes
    self.parameter = parameter
    self.delay = delay
  }

  public func preProcess() {

    targets.forEach { target in
      changes.forEach { change in
        change.preProcess(target: target)
      }
    }
  }

  public func make() -> AnimatorSet {

    let animator = parameter.build()
    animator.addAnimations {
      self.targets.forEach { target in
        self.changes.forEach { change in
          change.apply(target: target)
        }
      }
    }

    return AnimatorSet.init(coldAnimator: animator, delay: delay)
  }

  public func postProcess() {
    targets.forEach { target in
      changes.forEach { change in
        change.postProcess(target: target)
      }
    }
  }
}

@available(iOS 10, *)
extension ValueAnimation.ChangeSet {
  public static var hidden: ValueAnimation.ChangeSet<T> {
    return .init(
      target: \.isHidden,
      pre: false,
      to: true,
      post: false
    )
  }

  public static var fadeIn: ValueAnimation.ChangeSet<T> {
    return .init(
      target: \.alpha,
      pre: 0,
      to: 1,
      post: 1
    )
  }

  public static var fadeOut: ValueAnimation.ChangeSet<T> {
    return .init(
      target: \.alpha,
      pre: 1,
      to: 0,
      post: 1
    )
  }
}

@available(iOS 10, *)
extension ValueAnimation.ChangeSet {
  public static func transform(to: CGAffineTransform) -> ValueAnimation.ChangeSet<T> {
    return
      .init(
        target: \.transform,
        pre: nil,
        to: to,
        post: .identity
    )
  }

  public static func transform(from: CGAffineTransform) -> ValueAnimation.ChangeSet<T> {
    return
      .init(
        target: \.transform,
        pre: from,
        to: .identity,
        post: .identity
    )
  }

  public static func translateY(to: CGFloat) -> ValueAnimation.ChangeSet<T> {
    return transform(to: .init(translationX: 0, y: to))
  }

  public static func translateX(to: CGFloat) -> ValueAnimation.ChangeSet<T> {
    return transform(to: .init(translationX: to, y: 0))
  }

  public static func translateY(from: CGFloat) -> ValueAnimation.ChangeSet<T> {
    return transform(from: .init(translationX: 0, y: from))
  }

  public static func translateX(from: CGFloat) -> ValueAnimation.ChangeSet<T> {
    return transform(from: .init(translationX: from, y: 0))
  }

}
