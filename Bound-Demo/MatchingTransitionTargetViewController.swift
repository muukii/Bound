//
//  MatchingTransitionTargetViewController.swift
//  UICatalog
//
//  Created by muukii on 7/20/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

final class MatchingTransitionTargetViewController : UIViewController {

  @IBOutlet weak var box: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    TransitionStore.box.toBox = view
    TransitionStore.box.toBox = box
  }
}
