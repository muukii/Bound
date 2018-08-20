//
//  MatchedAnimationContext.swift
//  Transition
//
//  Created by muukii on 8/10/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

public final class MatchedAnimationContext {

  public let sourceView: UIView

  public let targetView: UIView

  public private(set) var frameForSourceViewInContainer: CGRect

  public private(set) var frameForTargetViewInContainer: CGRect

  public let containerView: UIView

  init(sourceView: UIView, targetView: UIView, in containerView: UIView) {

    self.sourceView = sourceView
    self.targetView = targetView
    self.containerView = containerView
    self.frameForSourceViewInContainer = sourceView.convert(sourceView.bounds, to: containerView)
    self.frameForTargetViewInContainer = targetView.convert(targetView.bounds, to: containerView)
  }

  func updateFramesInContainer() {
    self.frameForSourceViewInContainer = sourceView.convert(sourceView.bounds, to: containerView)
    self.frameForTargetViewInContainer = targetView.convert(targetView.bounds, to: containerView)
  }

}
