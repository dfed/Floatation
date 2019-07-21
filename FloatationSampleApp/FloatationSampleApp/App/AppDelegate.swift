//  Created by Dan Federman on 8/7/18.
//  Copyright © 2018 Dan Federman.

import Floatation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Set up the registry as soon as humanly possible after app launch.
        AppDelegate.setupRegistries()
        
        return true
    }

    static func setupRegistries() {
        RoutingRegistry.assignDesiredImplementation(to: RoutingRegistry(
            routeHandler: DefaultRouteHander(),
            weakURLOpener: WeakLazy() {
                return DefaultURLOpener(
                    routeBuilders: [
                        ProfileRouteBuilder.self,
                    ])
        })
        )
    }

}
