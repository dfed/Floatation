//  Created by Dan Federman on 7/21/19.
//  Copyright © 2019 Dan Federman.

import Foundation

public protocol URLOpener {

    func openURL(_ url: URL)

}

// Note: Default implementations can (and likely should) live in a different module.

public class DefaultURLOpener: URLOpener {

    // MARK: Lifecycle

    public init(
        routeHandler: RouteHander = RoutingRegistry.shared.routeHandler,
        routeBuilders: [RouteBuilder.Type])
    {
        self.routeHandler = routeHandler
        self.routeBuilders = routeBuilders
    }

    // MARK: URLOpener

    public func openURL(_ url: URL) {
        for builder in routeBuilders {
            if let route = builder.route(for: url) {
                routeHandler.handleRoute(route)
                break
            }
        }
    }

    // MARK: Private

    private let routeHandler: RouteHander
    private let routeBuilders: [RouteBuilder.Type]
}

// Note: Mocks would likely live in the same module as the protocol.

public class MockURLOpener: URLOpener {

    // MARK: Lifecycle

    public init() {}

    // MARK: URLOpener

    public func openURL(_ url: URL) {
        openedURLs.append(url)
    }

    // MARK: Internal

    internal var openedURLs = [URL]()

}
