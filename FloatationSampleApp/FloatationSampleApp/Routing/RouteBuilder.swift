//  Created by Dan Federman on 7/21/19.
//  Copyright © 2019 Dan Federman.

import Foundation

public protocol RouteBuilder {

    static func route(for url: URL) -> Route?

}
