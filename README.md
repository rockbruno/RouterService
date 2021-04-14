# RouterService

```swift
struct SwiftRocksFeature: Feature {

    @Dependency var client: HTTPClientProtocol
    @Dependency var persistence: PersistenceProtocol
    @Dependency var routerService: RouterServiceProtocol

    func build(fromRoute route: Route?) -> UIViewController {
        return SwiftRocksViewController(
            client: client,
            persistence: persistence,
            routerService: routerService,
        )
    }
}
```

RouterService is a type-safe navigation/dependency injection framework focused on making modular Swift apps have **very fast build times**. <a href="https://speakerdeck.com/amiekweon/the-evolution-of-routing-at-airbnb">Based on the system used at AirBnB presented at BA:Swiftable 2019.</a>

RouterService is meant to be used as a dependency injector for <a href="https://swiftrocks.com/reducing-ios-build-times-by-using-interface-targets">modular apps where each targets contains an additional "interface" module.</a> The linked article contains more info about that, but as a summary, this parts from the principle that a feature module should never directly depend on concrete modules. Instead, for build performance reasons, a feature only has access to another feature's **interface**, which contains protocols and other things that are unlikely to change. To link everything together, RouterService takes care of injecting the necessary concrete dependencies whenever one of these protocols is referenced.

The final result is:
 - An app with a horizontal dependency graph (very fast build times!)
 - Dynamic navigation (any screen can be pushed from anywhere!)

For more information on this architecture, <a href="https://swiftrocks.com/reducing-ios-build-times-by-using-interface-targets">check the related SwiftRocks article.</a>

## How RouterService Works

*(For a complete example, check this repo's example app.)*

RouterService works through the concept of `Features` -- which are `structs` that can create ViewControllers after being given access to whatever dependencies it needs to do that. Here's an example of how we can create an "user profile feature" using this format.

This feature requires access to a HTTP client, so we'll first define that. Since a modular app with interface targets should separate the protocol from the implementation, our first module will be a `HTTPClientInterface` that exposes the client protocol:

```swift
// Module 1: HTTPClientInterface

public protocol HTTPClientProtocol: AnyObject { /* Client stuff */ }
```

From the interface, let's now create a **concrete** `HTTPClient` module that implements it:

```swift
// Module 2: HTTPClient

import HTTPClientInterface

private class HTTPClient: HTTPClientProtocol { /* Implementation of the client stuff */ }
```

We're now ready to define our Profile RouterService feature. At a new `Profile` module, we can create a `Feature` struct that has the client's protocol as a dependency.
To have access to the protocol, the `Profile` module will import the dependency's interface.

```swift
// Module 3: Profile

import HTTPClientInterface
import RouterServiceInterface

struct ProfileFeature: Feature {

    @Dependency var client: HTTPClientProtocol

    func build(fromRoute route: Route?) -> UIViewController {
        return ProfileViewController(client: client)
    }
}
```

Because the `Profile` feature doesn't import the concrete `HTTPClient` module, changes made to them **will not recompile** the `Profile` module. Instead, RouterService will inject the concrete objects in runtime. If you multiply this by hundreds of protocols and dozens of features, you will get a massive build time improvement in your app!

In this case, the `Profile` feature will only be recompiled by external changes if the interface protocols themselves are changed -- which should be considerably rarer than changes to their concrete counterparts.

Let's now see how we can tell RouterService to push `ProfileFeature`'s ViewController.

## Routes

Instead of pushing features by directly creating instances of their ViewControllers, in RouterService, the navigation is done completely through `Routes`. By themselves, `Routes` are just `Codable` structs that can hold contextual information about an action (like the previous screen that triggered this route, for analytics purposes). However, the magic comes from how they are used: `Routes` are paired with `RouteHandlers`: classes that define a list of supported `Routes` and the `Features` that should be pushed when they are executed. 

For example, to expose the `ProfileFeature` shown above to the rest of the app, the hypothetical `Profile` target should first expose a route in a separate `ProfileInterface` target:

```swift
// Module 4: ProfileInterface

import RouterServiceInterface

struct ProfileRoute: Route {
    static let identifier: String = "profile_mainroute"
    let someAnalyticsContext: String
}
```

Now, at the concrete `Profile` target, we can define a `ProfileRouteHandler` that connects it to the `ProfileFeature`.

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
    ) -> Feature.Type {
        guard route is ProfileRoute else {
            preconditionFailure() // unexpected route sent to this handler
        }
        return ProfileFeature.self
    }
}
```

`RouteHandlers` are designed to handle multiple `Routes`. If a specific feature target contains multiple ViewControllers, you can have a single `RouteHandler` in that target that handles all of the possibles `Routes`.

To push a new `Feature`, all a `Feature` has to do is import the module that contains the desired `Route` and call the `RouterServiceProtocol` `navigate(_:)` method. `RouterServiceProtocol`, the interface protocol of the RouterService framework, can be added as a dependency of features for this purpose.

Assuming we also created some hypothetical `LoginFeature` alongside our `ProfileFeature`, here's how we could push `LoginFeature`'s ViewController from the `ProfileFeature`:

```swift
import LoginInterface
import RouterServiceInterface
import HTTPClientInterface
import UIKit

final class ProfileViewController: UIViewController {
    let client: HTTPClientProtocol
    let routerService: RouterServiceProtocol

    init(client: HTTPClientProtocol, routerService: RouterServiceProtocol) {
        self.client = client
        self.routerService = routerService
        super.init(nibName: nil, bundle: nil)
    }

    func goToLogin() {
        let loginRoute = SomeLoginRouteFromTheLoginFeatureInterface()
        routerService.navigate(
            toRoute: loginRoute,
            fromView: self,
            presentationStyle: Push(),
            animated: true
        )
    }
}
```

## Wrapping everything up

If all features are isolated, how do you start the app?

While the features are isolated from other concrete targets, you should have a "main" target that imports everything and everyone (for example, your AppDelegate). This should be the only target capable of importing concrete targets. 

From there, you can create a concrete instance of `RouterService`, register everyone's `RouteHandlers` and dependencies and start the navigation process loop by calling `RouterService's`: `navigationController(_:)` method (if you need a navigation), or by manually calling a `Feature's` `build(_:)` method.

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

## Providing fallbacks for Features

If you need to control the availability of your feature, either because of a feature flag or because it has a minimum iOS version requirement, it's possible to handle it through a `Feature's` `isEnabled()` method.
This method provides information to `RouterService` about the availability of your feature. We really recommend you to have your toggle controls (Feature Flag Provider, Remote Config Provider, User Defaults, etc) as a `@Dependency` of your feature so you can easily use them to implement it and properly unit test it later.
If a `Feature` can be disabled, you need to provide a fallback by implementing the `fallback(_:)` method to allow RouterService to receive and present a valid context. For example:
```swift
public struct FooFeature: Feature {

    @Dependency var httpClient: HTTPClientProtocol
    @Dependency var routerService: RouterServiceProtocol
    @Dependency var featureFlag: FeatureFlagProtocol

    public init() {}
    
    public func isEnabled() -> Bool {
        return featureFlag.isEnabled()
    }
    
    public func fallback(forRoute route: Route?) -> Feature.Type? {
        return MyFallbackFeature.self
    }

    public func build(fromRoute route: Route?) -> UIViewController {
        return MainViewController(
            httpClient: httpClient,
            routerService: routerService
        )
    }
}
```

If a disabled feature attempts to be presented without a fallback, your app will crash. By default, all features are enabled and have no fallbacks.

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

When installing RouterService, the interface module `RouterServiceInterface` will also be installed.

### Swift Package Manager

```swift
.package(url: "https://github.com/rockbruno/RouterService", .upToNextMinor(from: "1.1.0"))
```

### CocoaPods

```ruby
pod 'RouterService'
```

## Example Project

The [ExampleProject](ExampleProject) uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate its Xcode project. 

You can either install the XcodeGen binary with Homebrew, or leverage the Swift Package Manager, which will clone, build and then run XcodeGen. The individual steps to generate the `RouterServiceExampleApp.xcodeproj` are outlined below.

<details open>
<summary>Homebrew</summary>

```bash
# 1. Install XcodeGen using Homebrew
brew install xcodegen

# 2. Run xcodegen from within the ExampleProject directory
cd ExampleProject && xcodegen generate
```

</details>

<details open>
<summary>Swift Package Manager</summary>

```bash
# 1. Run xcodegen using SPM from within the ExampleProject directory
cd ExampleProject && swift run xcodegen
```

</details>
