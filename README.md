# Router Service

RouterService is a navigation/routing/dependency injection framework where all navigation is done through `Routes`. <a href="https://speakerdeck.com/amiekweon/the-evolution-of-routing-at-airbnb">Based on the system used at Airbnb presented at BA:Swiftable 2019.</a>

RouterService is meant to be as a dependency injector for <a href="https://swiftrocks.com/reducing-ios-build-times-by-using-interface-targets.html">modular apps where each targets contains an additional "interface" target.</a> The linked article contains more info about that, but as a summary, this starts from the principle that a feature target should never directly depend on another one. Instead, a feature only has access to another feature's interface, which contains RouterService's `Route` objects. RouterService then takes care of executing this `Route` and injecting the necessary dependencies.

The final result is:
 - An app with a horizontal dependency graph (very fast build times)
 - Dynamic navigation (any screen can be pushed from anywhere)

## How RouterService Works

Alongside a interfaced modular app, the **RouterService** framework attempts to improve build times by **completely severing the connections between ViewControllers.** This is how a RouterService app operates:

- You have a `Dependency` protocol, which can be any class instance needed by anyone at any point. (additional parameters like a screen's "context" **are not** dependencies)
- A `Feature` is a class that creates instances of a ViewController, given a list of said dependencies. **They are not public.** Here's an example:

Target: `HTTPClientInterface`, who imports `RouterServiceInterface`:

```swift
import RouterServiceInterface

protocol HTTPClientProtocol: Dependency {}
```

Target: `HTTPClient`, who imports `HTTPClientInterface`:

```swift
import HTTPClientInterface

class HTTPClient: HTTPClientProtocol { ... }
```

Target: `Profile`, who imports `HTTPClientInterface` and `RouterServiceInterface`, but **not** their concrete targets:

```swift
import HTTPClientInterface
import RouterServiceInterface

enum ProfileFeature: Feature {
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
        return ProfileViewController(...)
    }
}
```

Because the feature is isolated from the concrete client and other features, changes made to these targets will not recompile the `Profile` target, as the real instances will be injected in runtime by the RouterService. That's a big build time improvement!

## Routes

Instead of pushing features by directly creating instances of their ViewControllers, in RouterService, the navigation is done completely through `Routes`. By themselves, `Routes` are just `Codable` structs that can hold contextual information about an action (like the previous screen that triggered this route, for analytics purposes). However, the magic comes from how they are used: `Routes` are paired with `RouteHandlers`: classes that define a list of supported `Routes` and a method that returns which `Feature` should be pushed when a certain `Route` is executed. For example, to expose the `ProfileFeature` shown above to the rest of the app, the hypothetical `Profile` target could expose routes through its interface, and define a **public** `ProfileRouteHandler` like this:

Target: `ProfileInterface`, which depends on `RouterServiceInterface`:
```swift
struct ProfileRoute: Route {
    static let identifier: String = "profile_mainroute"
    let analyticsContext: String
}
```

Target: `Profile`, as seen before, but now also depending on `ProfileInterface`:

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
            preconditionFailure()
        }
        return AnyFeature(ProfileFeature.self)
    }
}
```

Now, to push a new `Feature`, all a `Feature` has to do is import its next feature's interface target and call the `navigate(_:)` method from the `RouterServiceProtocol` (which is accessible through the Feature's dependencies -- note how it is added as a dependency in the `ProfileFeature` example), sending the desired `Route` to be navigated to.

```swift
import SomeLoginInterface

let loginRoute = SomeLoginRouteFromTheLoginFeature()
dependencies.routerService.navigate(
    toRoute: loginRoute,
    fromView: self,
    presentationStyle: Push(),
    animated: true
)
```

Again, as `Profile` does not directly imports the concrete `SomeLogin` target, changes made to it will not recompile `Profile` unless the interface itself is changed.

## Tying everything up

If all features are isolated, how do you start the app?

While the features are isolated from the other targets, you should have a "main" target that imports everything and everyone. From there, you can create a concrete instance of your `RouterService` and register everyone's `RouteHandlers` and `Dependencies`.

```swift
import HTTPClient
import Profile
import Login

class AppDelegate {

   let routerService = RouterService()

   func didFinishLaunchingWith(...) {
       routerService.register(dependency: HTTPClient(), forType: HTTPClientProtocol.self)

       routerService.register(routeHandler: ProfileRouteHandler())
       routerService.register(routeHandler: LoginRouteHandler())

       //Your usual UIWindow stuff
       //...
       window.rootViewController = routerService.navigationController(withInitialFeature: ProfileFeature.self)

       return true
   }
}
```

For more information and examples, check the example app provided inside this repo.

## AnyRoute

All `Routes` are Codable, but what if more than one route can be returned by the backend?

For this purpose, RouterServiceInterface provides a type-erased `AnyRoute` that can decode any registered `Route` from a specific string format. This allows you to have your backend dictate how navigation should be handled inside the app.

`AnyRoute` is `Decodable`, so you should first add it to your backend's response model:

```swift
struct ProfileResponse: Decodable {
    let title: String
    let route: AnyRoute
}
```

But before decoding `ProfileResponse`, you need to inject a RouterService that contains the desired routes registered into the `JSONDecoder()` by using the relevant method from `RouterServiceProtocol`:

```swift
let decoder = JSONDecoder()

routerService.injectContext(toDecoder: decoder)

decoder.decode(ProfileResponse.self, from: data)
```

The string format expected by the framework is a string in the `route_identifier|parameters_json_string`. For example, to decode the `ProfileRoute` shown in the beginning of this README, `ProfileResponse` should look like this:

```json
{
    "title": "Profile Screen",
    "route": "profile_mainroute|{\"analyticsContext\": \"Home\"}"
}
```

## Installation

### CocoaPods

`pod 'RouterService'`
