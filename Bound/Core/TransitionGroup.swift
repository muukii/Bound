//
//  TransitionGroup.swift
//  Transition
//
//  Created by muukii on 8/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

@available(iOS 10, *)
public final class TransitionGroup : Hashable {

  public class func == (lhs: TransitionGroup, rhs: TransitionGroup) -> Bool {
    return lhs === rhs
  }

  public var hashValue: Int {
    return ObjectIdentifier.init(self).hashValue
  }

  public let matchedTransitions: [MatchedTransition]
  public let isolatedTransitions: [IsolatedTransition]

  public let estimatedTotalDuration: TimeInterval

  public init(
    matchedTransitions: [MatchedTransition] = [],
    isolatedTransitions: [IsolatedTransition] = []
    ) {
    self.matchedTransitions = matchedTransitions
    self.isolatedTransitions = isolatedTransitions
    self.estimatedTotalDuration = (matchedTransitions.map { $0.estimatedTotalDuration } + isolatedTransitions.map { $0.estimatedTotalDuration }).max() ?? 0
  }

  func applyBeforeProcess() {
    matchedTransitions.forEach { $0.applyBeforeProcess() }
    isolatedTransitions.forEach { $0.applyBeforeProcess() }
  }

  func run() -> [UIViewPropertyAnimator] {

    return
      [
        matchedTransitions.map { $0.run() },
        isolatedTransitions.compactMap { $0.run() },
        ]
        .flatMap { $0 }

  }

  func applyAfterProcess() {

    matchedTransitions.forEach { $0.applyAfterProcess() }
    isolatedTransitions.forEach { $0.applyAfterProcess() }

  }
}
