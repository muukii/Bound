//
//  Animator.swift
//  Transition
//
//  Created by muukii on 8/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

@available(iOS 10, *)
public final class Animator {

  public typealias TransitionGroupFactory = () throws -> TransitionGroup
  public typealias Completion = () -> Void

  private let preProcess: [Action]
  private let postProcess: [Action]
  private var transitionGroups: [(TransitionGroupFactory, Completion)] = []
  private var errorHandlers: [(Error) -> Void] = []

  ///
  ///
  /// - Parameters:
  ///   - preProcess:
  ///   - transitionGroupFactory:
  ///   - decoratedTransitionGroupFactory: The transitionGroup will not be included wait for calling completion-block.
  ///   - postProcess:
  public init(
    preProcess: [Action],
    postProcess: [Action]
    ) {

    self.preProcess = preProcess
    self.postProcess = postProcess
  }

  @discardableResult
  public func add(transitionGroup: TransitionGroup, completion: @escaping () -> Void) -> Self {
    transitionGroups.append(({ transitionGroup }, completion))
    return self
  }

  @discardableResult
  public func add(transitionGroupFactory: @escaping TransitionGroupFactory, completion: @escaping () -> Void) -> Self {
    transitionGroups.append((transitionGroupFactory, completion))
    return self
  }

  @discardableResult
  public func addErrorHandler(_ handler: @escaping (Error) -> Void) -> Self {
    errorHandlers.append(handler)
    return self
  }

  public func run(
    in transitionContext: UIViewControllerContextTransitioning
    ) {

    DispatchQueue.main.async {

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

      self.preProcess.forEach { $0.execute() }

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

        let groups = try self.transitionGroups.map { (try $0.0(), $0.1) }

        groups.forEach {
          $0.0.applyBeforeProcess()
        }

        avoidFlickerSnapshot.removeFromSuperview()

        /**
         Start Animations
         */

        let wholeGroup = DispatchGroup()

        groups.forEach {

          let (transitionGroup, completion) = $0
          let animatorsGroup = DispatchGroup()
          let animators = transitionGroup.run()

          animators.forEach {
            wholeGroup.enter()
            animatorsGroup.enter()
            $0.addCompletion { _ in
              wholeGroup.leave()
              animatorsGroup.leave()
            }
          }

          animatorsGroup.notify(queue: .main) {

            /**
             Animations did finish
             */

            UIView.performWithoutAnimation {
              transitionGroup.applyAfterProcess()
            }

            completion()
          }
        }

        wholeGroup.notify(queue: .main) {

          /**
           Animations did finish
           */

          UIView.performWithoutAnimation {
            self.postProcess.forEach { $0.execute() }
          }
        }
      } catch {
        avoidFlickerSnapshot.removeFromSuperview()
        self.errorHandlers.forEach { $0(error) }
      }

    }
  }
}
