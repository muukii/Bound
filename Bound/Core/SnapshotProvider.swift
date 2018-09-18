//
//  SnapshotBuilder.swift
//  Transition
//
//  Created by muukii on 7/18/18.
//  Copyright © 2018 eure. All rights reserved.
//

import UIKit

public struct SnapshotSource<T : UIView> {

  public let source: T

  public init(source: T) {
    self.source = source
  }

  public func render(_ render: @escaping (T) -> UIView) -> Snapshot {
    return Snapshot.init(source: source, build: render)
  }

  public func renderNormal(afterScreenUpdates: Bool = true) -> Snapshot {
    return .init(source: source) { source -> UIView in
      return source.__snapshotView(afterScreenUpdates: afterScreenUpdates) ?? UIView()
    }
  }

  @available(iOS 10.0, *)
  public func renderLayer(padding: UIEdgeInsets = .zero) -> Snapshot {
    return .init(source: source) { source in

      let scale = UIScreen.main.scale

      var size = source.bounds.size
      size.width += padding.left + padding.right
      size.height += padding.top + padding.bottom

      guard size.height != 0, size.width != 0 else {
        print("Context size.width or size.height must be more than 0pt.")
        return UIView()
      }

      let renderer = UIGraphicsImageRenderer(bounds: .init(origin: .zero, size: size))

      let image = renderer.image { (context) in
        context.cgContext.translateBy(x: padding.left, y: padding.top)
        let isHidden = source.isHidden
        source.isHidden = false
        source.layer.render(in: context.cgContext)
        source.isHidden = isHidden
      }

      let view = UIView(frame: CGRect(origin: .zero, size: size))
      view.layer.contents = image.cgImage!
      view.layer.contentsScale = scale
      view.layer.contentsGravity = "center"

      return view
    }
  }
}

public struct Snapshot {

  private let source: UIView
  private let _makeSnapshot: (UIView) -> UIView

  private var pipeline: [(UIView) -> Void] = []

  init<T: UIView>(source: T, build: @escaping (T) -> UIView) {
    self.source = source
    self._makeSnapshot = { view in
      build(view as! T)
    }
  }

  public func apply(_ execute: @escaping (UIView) -> Void) -> Snapshot {
    var s = self
    s.pipeline.append(execute)
    return s
  }

  public func build() -> UIView {
    let view = _makeSnapshot(source)
    pipeline.forEach { $0(view) }
    return view
  }
}


extension UIImage {
  @available(iOS 10, *)
  fileprivate class func imageWithView(view: UIView) -> UIImage {

    return
      UIGraphicsImageRenderer(bounds: view.bounds, format: .default())
        .image { _ in
          view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
          return
        }

  }
}

//struct ViewAttributes {
//
//  var alpha: CGFloat
//  var isHidden: Bool
//
//  var layerAttributes: LayerAttributes
//
//  init(from view: UIView) {
//
//    alpha = view.alpha
//    isHidden = view.isHidden
//  }
//}

struct LayerAttributes {

  var isHidden: Bool
  var cornerRadius: CGFloat
  var zPosition: CGFloat
  var opacity: Float
  var isOpaque: Bool
  var anchorPoint: CGPoint
  var masksToBounds: Bool
  var borderColor: CGColor?
  var borderWidth: CGFloat
  var contentsRect: CGRect
  var contentsScale: CGFloat

  static let flat = LayerAttributes(from: UIView().layer)

  init(from layer: CALayer) {
    isHidden = layer.isHidden
    cornerRadius = layer.cornerRadius
    zPosition = layer.zPosition
    opacity = layer.opacity
    isOpaque = layer.isOpaque
    anchorPoint = layer.anchorPoint
    masksToBounds = layer.masksToBounds
    borderColor = layer.borderColor
    borderWidth = layer.borderWidth
    contentsRect = layer.contentsRect
    contentsScale = layer.contentsScale
  }

}

extension CALayer {
  fileprivate func apply(attributes: LayerAttributes) {
    isHidden = attributes.isHidden
    cornerRadius = attributes.cornerRadius
    zPosition = attributes.zPosition
    opacity = attributes.opacity
    isOpaque = attributes.isOpaque
    anchorPoint = attributes.anchorPoint
    masksToBounds = attributes.masksToBounds
    borderColor = attributes.borderColor
    borderWidth = attributes.borderWidth
    contentsRect = attributes.contentsRect
//    contentsScale = attributes.contentsScale
  }
}

extension UIView {

  fileprivate func __snapshotView(afterScreenUpdates: Bool) -> UIView? {

    func __snapshot(afterScreenUpdates: Bool) -> UIView? {

      let snapshot = snapshotView(afterScreenUpdates: afterScreenUpdates)
      if #available(iOS 11.0, *), let oldSnapshot = snapshot {
        return SnapshotWrapperView(contentView: oldSnapshot)
      } else {
        return snapshot
      }
    }

    guard afterScreenUpdates else {
      return __snapshot(afterScreenUpdates: false)
    }

    let attributes = LayerAttributes(from: layer)

    layer.apply(attributes: .flat)

    defer {
      layer.apply(attributes: attributes)
    }

    guard let snapshot = __snapshot(afterScreenUpdates: true) else {
      return nil
    }

    snapshot.layer.allowsGroupOpacity = false

    snapshot.layer.apply(attributes: attributes)
    snapshot.layer.masksToBounds = true
    snapshot.isHidden = false
    snapshot.alpha = 1

    return snapshot
  }

}

final class SnapshotWrapperView: UIView {
  let contentView: UIView

  init(contentView: UIView) {

    self.contentView = contentView
    super.init(frame: contentView.frame)
    addSubview(contentView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = bounds
  }
}
