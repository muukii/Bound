//
//  ObjectStore.swift
//  Transition
//
//  Created by muukii on 8/19/18.
//  Copyright © 2018 eure. All rights reserved.
//

import Foundation

public enum ObjectStoreError : Error {
  case notFoundRequiredValue(storeName: String)
}

public protocol ObjectStoreType {
  associatedtype T
  var name: String { get }
  var value: T? { get set }
}

public extension ObjectStoreType {
  public mutating func purge() {
    self.value = nil
  }

  public func take() throws -> T {
    guard let value = value else {
      throw ObjectStoreError.notFoundRequiredValue(storeName: name)
    }
    return value
  }
}

public final class ObjectStore<T> : ObjectStoreType {

  public var value: T?
  public let name: String

  public init(name: String? = nil, file: String = #file, line: Int = #line) {
    self.name = name ?? "\(file).\(line)"
  }

}

public final class ObjectWeakStore<T : AnyObject> : ObjectStoreType {

  public weak var value: T?
  public let name: String

  public init(name: String? = nil, file: String = #file, line: Int = #line) {
    self.name = name ?? "\(file).\(line)"
  }

}
