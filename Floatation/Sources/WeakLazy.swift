//  Created by Dan Federman on 8/9/18.
//  Copyright © 2018 Dan Federman.

import Foundation

/// A class that vends an instance of type T that exists for as
/// long as the single instance is retained by another object.
public final class WeakLazy<T> {

  // MARK: Lifecycle

  /// Creates a WeakLazy with a block to build a lazily instantiated and weakly retained shared instance.
  ///
  /// - Parameter builder: A block that can be executed on any queue to create
  ///                      an instance of T. To prevent deadlocks, the builder block
  ///                      should not rely on other weak or lazy Singletons.
  public required init(builder: @escaping () -> T) {
    self.builder = builder
  }

  // MARK: Public

  /// The shared instance of this singleton.
  /// This instance must be retained by the caller.
  /// If the returned instance is released, the next time
  /// `shared` is called, a new instance will be created.
  public var instance: T {
    lock.lock()
    defer {
      lock.unlock()
    }
    if let existingInstance = weakInstance?.object {
      return existingInstance
    } else {
      let newInstance = builder()
      weakInstance = WeakObject(newInstance)
      return newInstance
    }
  }

  // MARK: Private

  private let builder: () -> T
  private let lock = NSLock()

  private var weakInstance: WeakObject<T>?

}

// A helper class to store generic objects weakly.
// For more info on weakly storing generics, read https://bugs.swift.org/browse/SR-55
private class WeakObject<T> {

  // MARK: Lifecycle

  fileprivate init(_ object: T) {
    // Swift 4 does not allow us to store generic class-bound protocols weakly,
    // so cast our object to AnyObject to store it weakly.
    weakObject = object as AnyObject
  }

  // MARK: Fileprivate

  fileprivate var object: T? {
    // Cast our weakly held AnyObject back to the type we expect.
    // This cast should only fail if our weakObject has been deallocated.
    return weakObject as? T
  }

  // MARK: Private

  private weak var weakObject: AnyObject?

}
