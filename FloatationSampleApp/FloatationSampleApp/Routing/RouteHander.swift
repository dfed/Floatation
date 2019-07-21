//  Created by Dan Federman on 7/21/19.
//  Copyright © 2019 Dan Federman.

import Foundation

public protocol Route {}

public protocol RouteHander {

    func handleRoute(_ route: Route)

}

// Note: Default implementations can (and likely should) live in a different module.

public class DefaultRouteHander: RouteHander {
    public init() {}

    // MARK: RouteHander

    public func handleRoute(_ route: Route) {
        // Show a screen for this route.
    }
}

// Note: Mocks would likely live in the same module as the protocol.

public class MockRouteHander: RouteHander {
    public init() {}

    // MARK: RouteHander

    public func handleRoute(_ route: Route) {
        handledRoutes.append(route)
    }

    // MARK: Internal

    internal var handledRoutes = [Route]()

}
