# Router Service

RouterService is a typesafe navigation/routing/dependency injection framework where all navigation is done through `Routes`. <a href="https://speakerdeck.com/amiekweon/the-evolution-of-routing-at-airbnb">Based on the system used at Airbnb presented at BA:Swiftable 2019.</a>

RouterService is meant to be as a dependency injector for <a href="https://swiftrocks.com/reducing-ios-build-times-by-using-interface-targets.html">modular apps where each targets contains an additional "interface" target.</a> The linked article contains more info about that, but as a summary, this parts from the principle that a feature target should never directly depend on another one. Instead, for build performance reasons, a feature only has access to another feature's **interface**, which contains RouterService's `Route` objects. Finally, RouterService takes care of executing said `Routes` by injecting the necessary dependencies into the route's destination feature.

The final result is:
 - An app with a horizontal dependency graph (very fast build times!)
 - Dynamic navigation (any screen can be pushed from anywhere!)

For more information on why this architecture is beneficial for Swift apps, <a href="https://swiftrocks.com/reducing-ios-build-times-by-using-interface-targets.html">check the related SwiftRocks article.</a>

## How RouterService Works

Alongside a interfaced modular app, the **RouterService** framework attempts to improve build times by **completely severing the connections between different ViewControllers.**
A RouterService app operates like this:

- A "dependency" is described through the `Dependency` protocol, which describes any class type that can be needed by a feature at some point in time, such as a HTTP client. ("additional parameters" like a screen's "context string" **are not** dependencies, only shared `class` objects.)
- A `Feature` is a caseless `enum` that, given a list of dependencies, creates a ViewController. Here's an example of how we can create a "profile feature" using this format in a modular Xcode project: (don't worry about how this is wrapped up -- we'll see that soon)

iOS Target 1: `HTTPClientInterface`, which imports `RouterServiceInterface`:

```swift
import RouterServiceInterface

public protocol HTTPClientProtocol: Dependency { /* Client stuff */ }
```

iOS Target 2: A **private** concrete `HTTPClient`, which imports `HTTPClientInterface`:

```swift
import HTTPClientInterface

private class HTTPClient: HTTPClientProtocol { /* Implementation of the client stuff */ }
```

iOS Target 3: A **private** `Profile`, which imports `HTTPClientInterface` and `RouterServiceInterface`, **but not their concrete versions**:

```swift
import HTTPClientInterface
import RouterServiceInterface

private enum ProfileFeature: Feature {
    struct Dependencies {
        let client: HTTPClientProtocol
        let routerService: RouterServiceProtocol
    }

    static var dependenciesInitializer: AnyDependenciesInitializer {
        return AnyDependenciesInitializer(Dependencies.init)
    }

    static func build(
        dependencies: ProfileFeature.Dependencies,
        fromRoute route: Route?
    ) -> UIViewController {
        return ProfileViewController(dependencies: dependencies)
    }
}
```

Because the `Profile` feature enum is isolated from the concrete `HTTPClient` target, changes made to the client **will not recompile** the `Profile` target, as the real instances are injected in runtime by the RouterService. If you multiply this by hundreds of protocols and dozens of features, you will get a massive build time improvement in your app!

In this case, the `Profile` feature will only be recompiled by external changes if the interface protocols themselves are changed -- which should be considerably rarer than changes to their concrete counterparts.

## Routes

Instead of pushing features by directly creating instances of their ViewControllers, in RouterService, the navigation is done completely through `Routes`. By themselves, `Routes` are just `Codable` structs that can hold contextual information about an action (like the previous screen that triggered this route, for analytics purposes). However, the magic comes from how they are used: `Routes` are paired with `RouteHandlers`: classes that define a list of supported `Routes` and the `Features` that should be pushed when they are executed. For example, to expose the `ProfileFeature` shown above to the rest of the app, the hypothetical `Profile` target could expose routes through a separate `ProfileInterface` target, and define a **public** `ProfileRouteHandler` struct like this:

iOS Target 4: `ProfileInterface`, which depends on `RouterServiceInterface`:
```swift
import RouterServiceInterface

struct ProfileRoute: Route {
    static let identifier: String = "profile_mainroute"
    let someAnalyticsContext: String
}
```

iOS Target 3: The concrete `Profile` that we have created before, but now also depending on `ProfileInterface`:

```swift
import ProfileInterface
import RouterServiceInterface

public final class ProfileRouteHandler: RouteHandler {
    public var routes: [Route.Type] {
        return [ProfileRoute.self]
    }

    public func destination(
        forRoute route: Route,
        fromViewController viewController: UIViewController
    ) -> AnyFeature {
        guard route is ProfileRoute else {
            preconditionFailure() // unexpected route sent to this handler
        }
        return AnyFeature(ProfileFeature.self)
    }
}
```

`RouteHandlers` are designed to handle multiple `Routes`. If a specific feature target contains multiple ViewControllers, the intended usage is for you to have a single `RouteHandler` in that target that handles all of the possibles `Routes`.

To push a new `Feature`, all a `Feature` has to do is import the desired `Feature`'s interface and call the `RouterServiceProtocol` `navigate(_:)` method. `RouterServiceProtocol`, the interface protocol of the RouterService framework, is acessible in all features as a dependency.

Assuming we also created some hypothetical `LoginFeature` alongside our `ProfileFeature`, here's how we could push `LoginFeature`'s ViewController from `ProfileFeature`'s target:

```swift
import LoginInterface
import RouterServiceInterface
import UIKit

final class ProfileViewController: UIViewController {
    let dependencies: ProfileFeature.Dependencies

    init(dependencies: ProfileFeature.Dependencies) {
        self.dependencies = dependencies
        super.init(nibName: nil, bundle: nil)
    }

    func goToLogin() {
        let loginRoute = SomeLoginRouteFromTheLoginFeatureInterface()
        dependencies.routerService.navigate(
            toRoute: loginRoute,
            fromView: self,
            presentationStyle: Push(),
            animated: true
        )
    }
}
```

Again, as `Profile` does not directly imports the concrete `SomeLogin` target, changes made to it will not recompile `Profile` unless the interface itself is changed. The ViewController that is going to be pushed will be defined by the `Feature` that is returned by `LoginFeature`'s registered `RouteHandler` for that specific route.

## Wrapping everything up

If all features are isolated, how do you start the app?

While the features are isolated from the other targets, you should have a "main" target that imports everything and everyone, ideally the same target that contains your `AppDelegate` to minimize possible build time impacts. This should be the only target capable of importing concrete targets. 

From there, you can create a concrete instance of your `RouterService`, register everyone's `RouteHandlers` and `Dependencies` and start the navigation process loop by calling `RouterService's`: `navigationController(_:)` method (if you need a navigation), or by manually calling a `Feature's` `build(_:)` method.

```swift
import HTTPClient
import Profile
import Login

class AppDelegate {

   let routerService = RouterService()

   func didFinishLaunchingWith(...) {

       // Register Dependencies

       routerService.register(dependencyFactory: { 
           return HTTPClient() 
       }, forType: HTTPClientProtocol.self)

       // Register RouteHandlers

       routerService.register(routeHandler: ProfileRouteHandler())
       routerService.register(routeHandler: LoginRouteHandler())

       // Setup Window

       let window = UIWindow()
       window.makeKeyAndVisible()

       // Start RouterService

       window.rootViewController = routerService.navigationController(
        withInitialFeature: ProfileFeature.self
       )

       return true
   }
}
```

For more information and examples, check the example app provided inside this repo. It contains an app with two features targets and a fake dependency target.

## Memory Management of Dependencies

Dependencies are registered through closures (called "dependency factories") to allow RouterService to generate their instances on demand and deallocate them when no feature that needs them is active. This is done by having an internal store that holds the values weakly. The closures themselves are held in memory throughout the entire lifecycle of the app, but should be less impactful than holding the instances themselves.

## AnyRoute

All `Routes` are Codable, but what if more than one route can be returned by the backend?

For this purpose, RouterServiceInterface provides a type-erased `AnyRoute` that can decode any registered `Route` from a specific string format. This allows you to have your backend dictate how navigation should be handled inside the app. Cool, right?

To use it, add `AnyRoute` (which is `Decodable`) to your backend's response model:

```swift
struct ProfileResponse: Decodable {
    let title: String
    let anyRoute: AnyRoute
}
```

Before decoding `ProfileResponse`, inject your RouterService instance in the `JSONDecoder`: (necessary to determine which Route should be decoded)

```swift
let decoder = JSONDecoder()

routerService.injectContext(toDecoder: decoder)

decoder.decode(ProfileResponse.self, from: data)
```

You can now decode `ProfileResponse`. If the injected RouterService contains the Route returned by the backend, `AnyRoute` will successfully decode to it.

```swift
let response = decoder.decode(ProfileResponse.self, from: data)
print(response.anyRoute.route) // Route
```

The string format expected by the framework is a string in the `route_identifier|parameters_json_string` format. For example, to decode the `ProfileRoute` shown in the beginning of this README, `ProfileResponse` should look like this:

```json
{
    "title": "Profile Screen",
    "anyRoute": "profile_mainroute|{\"analyticsContext\": \"Home\"}"
}
```

## Installation

RouterService and its `RouterServiceInterface` interface are available through CocoaPods.

`pod 'RouterService'`
