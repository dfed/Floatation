//  Created by Dan Federman on 8/7/18.
//  Copyright © 2018 Dan Federman.

import Foundation

public protocol ScreenPresenter {}

// Note: Default implementations would likely live in their own feature module.

public class MockScreenPresenter: ScreenPresenter {
  public init() {}
}

// Note: Mocks would likely live in the same module as the protocol.

public class DefaultScreenPresenter: ScreenPresenter {
  public init() {}
}
