//
//  Transition.swift
//  Transition
//
//  Created by muukii on 7/11/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

public struct Action {

  private let _execute: () -> Void

  public init(_ execute: @escaping () -> Void) {
    self._execute = execute
  }

  public func execute() {
    _execute()
  }
}

public enum TransitionStep {
  case before
  case main
  case after
}

public enum AfterProcessTiming {
  case whenAnimationFinished
  case whenAllAnimationsFinished
}

