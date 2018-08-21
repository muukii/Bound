//
//  InViewBasicTransitionViewController.swift
//  Bound-Demo
//
//  Created by muukii on 8/22/18.
//  Copyright © 2018 muukii. All rights reserved.
//

import UIKit

import Bound

final class InViewBasicTransitionViewController : ViewControllerBase {

  @IBOutlet weak var fromView: UIView!
  @IBOutlet weak var toView: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()

    toView.alpha = 0
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    Animator(
      preProcess: [],
      postProcess: [
        .init {
          self.fromView.alpha = 0
        }
      ]
      )
      .add(transitionGroup: .init(
        matchedTransitions: [
          MatchedTransition.init(
            source: fromView,
            target: toView,
            animation: MatchedAnimations.Crossfade(
              sourceSnapshot: SnapshotSource(source: fromView).renderNormal(),
              targetSnapshot: SnapshotSource(source: toView).renderNormal()
            ),
            animatorOptions: .init(duration: 0.5, dampingRatio: 0.9),
            in: view
          )
        ]
      )) {

      }
      .run()

  }
}
