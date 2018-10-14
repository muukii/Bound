//
//  MatchingTransitionViewController.swift
//  Transition-Demo
//
//  Created by muukii on 7/18/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

import Bound

enum TransitionStore {

  final class Box {

    weak var fromBox: UIView?
    weak var toBox: UIView?
    weak var toView: UIView?

    init() {}
  }

  static let box: Box = .init()

}

final class MatchingTransitionViewController : UIViewController {

  @IBOutlet weak var fromBox: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()

//    fromBox.layer.cornerRadius = 8
//    toBox.layer.cornerRadius = 8
//    toBox.isHidden = true

    navigationController?.delegate = self
    TransitionStore.box.fromBox = fromBox
//    transitioningDelegate = self
  }

  @IBAction func didTapStartButton() {

    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MatchingTransitionTargetViewController")
//    vc.transitioningDelegate = self
//    vc.modalPresentationStyle = .custom

    navigationController?.pushViewController(vc, animated: true)

//    present(vc, animated: true, completion: nil)
  }
}

extension MatchingTransitionViewController : UIViewControllerTransitioningDelegate {

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//    return TransitionController()
    return nil
  }
}

extension MatchingTransitionViewController : UINavigationControllerDelegate {

  func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

    switch operation {
    case .push:
      return
        AutomatedPushTransitionController { (container) in

          container.animator.addGroupFactory({ (context, group) in

            group.add(
              animation: MatchedAnimations.Crossfade(
                sourceSnapshot: context.makeSnapshot(from: TransitionStore.box.fromBox!),
                targetSnapshot: context.makeSnapshot(from: TransitionStore.box.toBox!),
                path: context.makePath(to: TransitionStore.box.toBox!, from: TransitionStore.box.fromBox!),
                parameter: .init(duration: 0.5, dampingRatio: 0.9),
                containerView: context.containerView
              )
            )

            group.add(
              animation: ValueAnimation.init(
                targets: [
                  TransitionStore.box.toView
                ],
                changes: [.fadeIn],
                parameter: .init(duration: 0.3, curve: .easeOut),
                delay: 0.5
              )
            )

          }, completion: {
            container.notifyTransitionCompleted()
          })

      }
    case .pop:
      return BasicNavigationTransitionController(operation: .pop)
    case .none:
      fatalError()
    }
    
  }

  func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return nil
  }
}

/*
final class TransitionController : NSObject, UIViewControllerAnimatedTransitioning {

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    guard transitionContext.viewController(forKey: .from) is MatchingTransitionViewController else {

      transitionContext.containerView.insertSubview(transitionContext.viewController(forKey: .to)!.view, at: 0)
      transitionContext.completeTransition(true)
      return
    }

    let from = transitionContext.viewController(forKey: .from)! as! MatchingTransitionViewController
    let to = transitionContext.viewController(forKey: .to)! as! MatchingTransitionTargetViewController

    let containerView = transitionContext.containerView

//    transitionContext.completeTransition(true)

    Animator.init(
      preProcess: [
//        .init {
//          containerView.addSubview(to.view)
//        }
      ],
      transitionGroup: .init(
        matchedTransitions: [
          MatchedTransition.init(
            sourceView: containerView.findComponent(by: TransitionTags.fromBox)!.target!,
            targetView: to.view.findComponent(by: TransitionTags.toBox)!.target!,
            animation: MatchedAnimations.Crossfade(),
            animatorOptions: .init(duration: 0.3, dampingRatio: 0.7),
            in: containerView
          ),
          ],
        isolatedTransitions: [
          .init(
            targets: to.view.findComponent(by: TransitionTags.toView)!.target!,
            animations: [IsolatedAnimations.fadeIn],
            delay: 0.5,
            animatorOptions: .init(duration: 0.3, curve: .easeOut)
          ),

        ]
      ),
      postProcess: [

      ]
      )
      .run(in: transitionContext) {
        transitionContext.completeTransition(true)
    }

  }

}

 */
