//  Created by Dan Federman on 7/21/19.
//  Copyright © 2019 Dan Federman.

import Foundation

public struct ProfileRoute: Route {

    internal let identifier: String

}

public class ProfileRouteBuilder: RouteBuilder {

    public static func route(for url: URL) -> Route? {
        var pathComponents = url.pathComponents
        guard pathComponents.first == "profile" else {
            return nil
        }

        pathComponents = Array(pathComponents.dropFirst())

        guard let user = pathComponents.first else {
            return nil
        }

        return ProfileRoute(identifier: user)
    }

}
