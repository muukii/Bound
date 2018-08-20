//
//  LayerView.swift
//  Transition
//
//  Created by muukii on 8/15/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

open class LayerView<T : CALayer> : UIView {

  open override class var layerClass: Swift.AnyClass {
    return T.self
  }

  open var typedLayer: T {
    return layer as! T
  }
}
