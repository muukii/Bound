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

  func add(animation: Animating) {
    animations.append(animation)
  }
}

@available(iOS 10.0, *)
public final class TransitionContext {

  func makeSnapshot<T: UIView, S: UIView>(
    from: T,
    render: (SnapshotSource<T>) -> S,
    in containerView: UIView
    ) -> S {

    let source = SnapshotSource<T>(source: from)
    let view = render(source)
    //    let center = from.convert(from.center, to: containerView)
    //    view.center = center

    return view
  }

  func makePath(to: UIView, from: UIView, in containerView: UIView) -> MatchedAnimations.MovePath {

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

@available(iOS 10, *)
public final class Animator {

  public typealias GroupFactory = (TransitionContext, TransitionGroup) throws -> Void
  public typealias Completion = () -> Void

  private let context: TransitionContext

  private var groupFactories: [(GroupFactory, Completion)] = []

  private var wholeCompletion: () -> Void = {}

  private var errorHandlers: [(Error) -> Void] = []

  init() {
    self.context = TransitionContext()
  }

  @discardableResult
  func addGroupFactory(_ groupFactory: @escaping GroupFactory, completion: @escaping Completion) -> Self {
    self.groupFactories.append((groupFactory, completion))
    return self
  }

  @discardableResult
  func addWholeCompletion(_ wholeCompletion: @escaping () -> Void) -> Self {
    self.wholeCompletion = wholeCompletion
    return self
  }

  @discardableResult
  public func addErrorHandler(_ handler: @escaping (Error) -> Void) -> Self {
    errorHandlers.append(handler)
    return self
  }

  public func run() {

    do {

      let items = try self.groupFactories.map { args -> (TransitionGroup, Completion) in
        let group = TransitionGroup()
        try args.0(self.context, group)
        return (group, args.1)
      }

      items.forEach {
        $0.0.animations.forEach {
          $0.preProcess()
        }
      }

      /**
       Start Animations
       */

      let wholeGroup = DispatchGroup()

      wholeGroup.enter()
      items.forEach { args in

        let group = DispatchGroup()

        args.0.animations.forEach {
          group.enter()
          let set = $0.make()
          set.coldAnimator.startAnimation(afterDelay: set.delay)
          set.coldAnimator.addCompletion { _ in
            group.leave()
          }
        }

        group.notify(queue: .main) {
          wholeGroup.leave()
          args.1()
        }
      }

      wholeGroup.notify(queue: .main) {

        /**
         Animations did finish
         */

        UIView.performWithoutAnimation {
          items.forEach {
            $0.0.animations.forEach {
              $0.postProcess()
            }
          }
        }

        self.wholeCompletion()
      }
    } catch {    
      self.errorHandlers.forEach { $0(error) }
    }
  }

  public func run(
    in transitionContext: UIViewControllerContextTransitioning
    ) {

    /**
     This dispatching is for transition in NavigationController.
     Transition of NavigationController starts on commit of CATransaction.
     It will cause failure to snapshot of UIView.
     */

    /**
     Workaround:
     To take snapshot exactly, It needs to separate CATransaction as two, but this approach may cause flicker.
     To avoid, take the snapshot for containerView and then addSubview.
     Remove this snapshot on second CATransaction.
     */

    /**
     First Transaction
     */

    let avoidFlickerSnapshot = transitionContext.containerView.snapshotView(afterScreenUpdates: false) ?? UIView()

    transitionContext.containerView.addSubview(avoidFlickerSnapshot)

    layout: do {

      /**
       To apply tasks that UIKit has.
       e.g safeAreaInsets, contentInsets
       */ transitionContext.containerView.layoutIfNeeded()
    }

    /**
     Second Transaction
     */

    do {

      let items = try self.groupFactories.map { args -> (TransitionGroup, Completion) in
        let group = TransitionGroup()
        try args.0(self.context, group)
        return (group, args.1)
      }

      items.forEach {
        $0.0.animations.forEach {
          $0.preProcess()
        }
      }

      avoidFlickerSnapshot.removeFromSuperview()

      /**
       Start Animations
       */

      let wholeGroup = DispatchGroup()

      wholeGroup.enter()
      items.forEach { args in

        let group = DispatchGroup()

        args.0.animations.forEach {
          group.enter()
          let set = $0.make()
          set.coldAnimator.startAnimation(afterDelay: set.delay)
          set.coldAnimator.addCompletion { _ in
            group.leave()
          }
        }

        group.notify(queue: .main) {
          wholeGroup.leave()
          args.1()
        }
      }

      wholeGroup.notify(queue: .main) {

        /**
         Animations did finish
         */

        UIView.performWithoutAnimation {
          items.forEach {
            $0.0.animations.forEach {
              $0.postProcess()
            }
          }
        }

        self.wholeCompletion()
      }
    } catch {
      avoidFlickerSnapshot.removeFromSuperview()
      self.errorHandlers.forEach { $0(error) }
    }
  }
}
