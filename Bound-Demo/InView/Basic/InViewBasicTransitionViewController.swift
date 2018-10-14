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

    self.fromView.alpha = 0

    Animator()
      .addGroupFactory({ (context, group) in

        group.add(animation: MatchedAnimations.Crossfade(
          sourceSnapshot: context.makeSnapshot(from: self.fromView),
          targetSnapshot: context.makeSnapshot(from: self.toView),
          path: context.makePath(to: self.toView, from: self.fromView),
          parameter: .init(duration: 0.5, dampingRatio: 0.9),
          containerView: self.view
          )
        )
      }) {

      }
      .run(in: self.view)


  }
}
