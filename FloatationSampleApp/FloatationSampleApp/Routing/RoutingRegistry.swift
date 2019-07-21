//  Created by Dan Federman on 8/7/18.
//  Copyright © 2018 Dan Federman.

import Floatation
import Foundation

public final class RoutingRegistry: Registry {
    
    // MARK: Lifecycle
    
    public required init(
        routeHandler: RouteHander,
        weakURLOpener: WeakLazy<URLOpener>)
    {
        self.routeHandler = routeHandler
        self.weakURLOpener = weakURLOpener
        
        super.init()
    }
    
    // MARK: Registry
    
    public static func createMockShared() -> RoutingRegistry {
        return RoutingRegistry(
            routeHandler: MockRouteHander(),
            weakURLOpener: WeakLazy() { MockURLOpener() })
    }
    
    // MARK: Public
    
    public let routeHandler: RouteHander

    public var urlOpener: URLOpener {
        return weakURLOpener.instance
    }

    // MARK: Private

    private let weakURLOpener: WeakLazy<URLOpener>
    
}
