//  Created by Dan Federman on 8/17/18.
//  Copyright © 2018 Dan Federman.

import Foundation

/// A class that vends an instance of type T that is created on first access.
public final class Lazy<T: AnyObject> {

  // MARK: Lifecycle

  /// Creates a Lazy with a block to build the lazily instantiated shared instance.
  ///
  /// - Parameter builder: A block that can be executed on any queue to create
  ///                      an instance of T. To prevent deadlocks, the builder block
  ///                      should not rely on other weak or lazy Singletons.
  public required init(builder: @escaping () -> T) {
    self.builder = builder
  }

  // MARK: Public

  /// The shared instance of this singleton.
  public var instance: T {
    lock.lock()
    defer {
      lock.unlock()
    }
    if let existingInstance = sharedInstance {
      return existingInstance
    } else {
      let newInstance = builder()
      sharedInstance = newInstance
      return newInstance
    }
  }

  // MARK: Private

  private let builder: () -> T
  private let lock = NSLock()

  private var sharedInstance: T?

}
