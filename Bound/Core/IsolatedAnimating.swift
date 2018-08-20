//
//  Default.swift
//  Transition
//
//  Created by muukii on 7/11/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

public protocol IsolatedAnimating {
  func apply(to view: UIView, in step: TransitionStep)
}

public struct AnonymousIsolatedAnimation : IsolatedAnimating {

  private let _apply: (UIView, TransitionStep) -> Void

  public init(
    apply: @escaping (UIView, TransitionStep) -> Void
    ) {
    self._apply = apply
  }

  public init<V>(
    keyPath: ReferenceWritableKeyPath<UIView, V>,
    preProcess: @autoclosure @escaping () -> V?,
    apply: @autoclosure @escaping () -> V,
    postProcess: @autoclosure @escaping () -> V?
    ) {

    self.init { view, step in
      switch step {
      case .before:
        if let value = preProcess() {
          view[keyPath: keyPath] = value
        }
      case .main:
        view[keyPath: keyPath] = apply()
      case .after:
        if let value = postProcess() {
          view[keyPath: keyPath] = value
        }
      }
    }

  }

  public func apply(to view: UIView, in step: TransitionStep) {
    _apply(view, step)
  }
}

/// Alpha Controls
@available(iOS 10, *)
public enum IsolatedAnimations {}

@available(iOS 10, *)
extension IsolatedAnimations {
  public static let hidden: AnonymousIsolatedAnimation = .init(
    keyPath: \.isHidden,
    preProcess: false,
    apply: true,
    postProcess: false
  )

  public static let fadeIn: AnonymousIsolatedAnimation = .init(
    keyPath: \.alpha,
    preProcess: 0,
    apply: 1,
    postProcess: 1
  )

  public static let fadeOut: AnonymousIsolatedAnimation = .init(
    keyPath: \.alpha,
    preProcess: 1,
    apply: 0,
    postProcess: 1
  )
}

/// Transformations
@available(iOS 10, *)
extension IsolatedAnimations {

  public static func transform(to: CGAffineTransform) -> AnonymousIsolatedAnimation {
    return
      .init(
        keyPath: \.transform,
        preProcess: nil,
        apply: to,
        postProcess: .identity
    )
  }

  public static func transform(from: CGAffineTransform) -> AnonymousIsolatedAnimation {
    return
      .init(
        keyPath: \.transform,
        preProcess: from,
        apply: .identity,
        postProcess: .identity
    )
  }

  public static func translateY(to: CGFloat) -> AnonymousIsolatedAnimation {
    return transform(to: .init(translationX: 0, y: to))
  }

  public static func translateX(to: CGFloat) -> AnonymousIsolatedAnimation {
    return transform(to: .init(translationX: to, y: 0))
  }

  public static func translateY(from: CGFloat) -> AnonymousIsolatedAnimation {
    return transform(from: .init(translationX: 0, y: from))
  }

  public static func translateX(from: CGFloat) -> AnonymousIsolatedAnimation {
    return transform(from: .init(translationX: from, y: 0))
  }
}
