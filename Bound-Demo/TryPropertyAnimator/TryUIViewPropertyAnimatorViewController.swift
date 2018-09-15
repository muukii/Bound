//
//  TryUIViewPropertyAnimatorViewController.swift
//  Transition-Demo
//
//  Created by muukii on 8/18/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

import Bound

final class TryUIViewPropertyAnimatorViewController : UIViewController {

  @IBOutlet private weak var boxView: UIView!
  @IBOutlet private weak var box2View: UIView!
  @IBOutlet private weak var slider: UISlider!

  var animators: [UIViewPropertyAnimator] = []

  override func viewDidLoad() {
    super.viewDidLoad()

//    Animator.init(preProcess: [], postProcess: [])
//      .add(transitionGroup:
//        .init(
//          isolatedTransitions: [
//            IsolatedTransition(
//              targets: [boxView],
//              animations: [IsolatedAnimations.translateX(from: -100)],
//              animatorOptions: .init(duration: 0.5, dampingRatio: 0.4)
//            )
//          ]
//        )
//      ) {
//
//    }

  }

  override func viewWillDisappear(_ animated: Bool) {

//    animators.forEach {
//      $0.stopAnimation(true)
//    }

    super.viewWillDisappear(animated)
  }

  @IBAction func didTapButton(_ sender: Any) {

    animators = []

    do {
      let animator = UIViewPropertyAnimator(duration: 10, dampingRatio: 0.3)

      animator.addAnimations({
        self.boxView.transform = .init(translationX: -100, y: 0)
      }, delayFactor: 0.5)

      animator.addCompletion { (position) in
        print("finish 1", position.rawValue)
      }

//      animator.startAnimation()
      animator.pauseAnimation()

      animators.append(animator)
    }

    do {

      let animator = UIViewPropertyAnimator(duration: 2, curve: .easeInOut)

      animator.addAnimations({
        self.box2View.transform = .init(translationX: 100, y: 0)
      }, delayFactor: 0.5)

      animator.addCompletion { (position) in
        print("finish 2", position.rawValue)
      }

      animator.pauseAnimation()

      animators.append(animator)
    }

  }

  @IBAction func didTapStartButton(_ sender: Any) {
    self.animators.forEach {
//      $0.startAnimation()
      $0.continueAnimation(withTimingParameters: nil, durationFactor: 0)
    }
  }

  @IBAction func valueChanged(_ sender: Any) {
    self.animators.forEach {
      $0.fractionComplete = CGFloat(slider.value)
    }
  }
}
