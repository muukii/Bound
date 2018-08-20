//
//  Utils.swift
//  Transition
//
//  Created by muukii on 7/19/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

public enum TransitionUtils {

  public static func makeCGAffineTransform(from: CGRect, to: CGRect) -> CGAffineTransform {

    return .init(
      a: to.width / from.width,
      b: 0,
      c: 0,
      d: to.height / from.height,
      tx: to.midX - from.midX,
      ty: to.midY - from.midY
    )
  }
}
