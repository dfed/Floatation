# Archived Project

This package has been abandoned in favor of the compile-time safe DI solution [SafeDI](https://github.com/dfed/safedi).

# Floatation

## Overview

Floatation is a lightweight dependency injection framework that makes it easy to surface dependencies to consuming code. It is designed to minimize the burden of incremental adoption in a large codebase.

## Usage

Floatation makes accessing dependencies as easy as referencing `YourRegistry.shared.yourDependency`, without sacrificing testability.

A `Registry` is a `final class` that declares `let` properties. Each Registry vends an instance of itself via a `static var shared: Self { get }` that is implemented in an extension on `Registry`.

An example Registry:

```swift
public final class CoreRegistry: Registry {

  // MARK: Lifecycle

  public required init(
    experimentLauncher: ExperimentLauncher,
    userDefaults: KeyValueStore)
  {
    self.experimentLauncher = experimentLauncher
    self.userDefaults = userDefaults

    super.init()
  }

  // MARK: Registry

  public static func createMockShared() -> CoreRegistry {
    return CoreRegistry(
      experimentLauncher: MockExperimentLauncher(),
      userDefaults: MockKeyValueStore())
  }

  // MARK: Public

  public let experimentLauncher: ExperimentLauncher
  public let userDefaults: KeyValueStore

}
```

Note that the `CoreRegistry` vends a `createMockShared()` static method. This method is used to create the default value for the static shared property. Because Registries all vend a mock value, all properties can be `nonnull`.

It is the responsibility of the main app target to override the mock with a desired implementation; all `Registry` objects have a `func assignDesiredImplementation(to shared: Self)` method that accept only one desired implementation per `Registry`. As all `Registry` instances are set up once at runtime in `applicationDidFinishLaunching` – we have unit test to ensure this does not regress – it'll be impossible for downstream code to override the shared state.

As promised, accessing a property on a `Registry` is exceptionally simple:

```swift
final class FeatureViewController: UIViewController {

  // MARK: Lifecycle

  init(experimentLauncher: ExperimentLauncher = CoreRegistry.shared.experimentLauncher) {
    // …
  }

}
```

Because each framework in your workspace can define its own `Registry`, and because each `Registry` only requires direct knowledge of the protocol and mock implementation of its vended properties, `Floatation` works well with flat dependency trees.

Additionally, tests can configure mocks on a framework's `Registry` however they choose, without needing to pull in the default implementation from another framework. The ability to configure mocks per Registry allows teams to easily set up global state for their tests.

### Advantages and Disadvantages of this approach

#### Advantages

* Extremely easy to access shared dependencies – shallow learning curve.
* Configuration of `Registry` objects at runtime is simple.
* Vended properties are non-null.
* Unit testing is simple.
    * Registries vend a shared mocked instance of themselves if not configured to use a desired implementation, making unit testing trivial.
    * Every `Registry` is automatically reset between unit tests.
* Plays nicely with a flat dependency tree.

#### Disadvantages

* No compile-time safety-blanket. There is no build-time guarantee that all `Registry` types have had a desired implementation set. However, it is easy to set up a unit test to ensure that a desired implementation is set for every `Registry` at app launch.
* Floatation relies on convention.
    * A `Registry` in Floatation should have all of its protocol-conforming or closure-backed properties injectable via the initializer in order to enforce compile-time errors in configuration code when a new dependency is added. If an engineer bucks this trend, that hardcoded property (which may be a mocked value) could make its way into the app.
* There is no way to limit access to a dependency to a subset of an individual module – dependencies vended via a Registry must have an access control of either internal or public.
* Mock classes must be built alongside default implementations in the main app target.

### Detailed Design

#### Creating a Registry

There are just a few steps for creating your own registry:

1. import Floatation
2. Create a new final class that extends Registry
3. Declare your properties, ensuring that each property is an instance of protocol (per normal DI rules, no hard instances allowed!)
4. Create an initializer that allows you to inject hard instances into the registry
5. Implement createMockShared() to create an instance of your registry with only Mock objects.

We've made this easy by creating an [Xcode template for a new registry](https://github.com/dfed/Floatation/blob/master/FloatationRegistry.xctemplate). You can install this template by running the following commands from the root of the Floatation repo:
```bash
mkdir -p ~/Library/Developer/Xcode/Templates/Custom
cp -R FloatationRegistry.xctemplate ~/Library/Developer/Xcode/Templates/Custom/
```

#### Setting up a registry in the main app target

A Registry is configured in the AppDelegate as follows:

```swift
func application(
  _ application: UIApplication,
  willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
{
  // Set up the registry as soon as possible after app launch.
  setupRegistries()

  return true
}

private func setupRegistries() {
  RoutingRegistry.assignDesiredImplementation(to: RoutingRegistry(
    routeHandler: DefaultRouteHander(),
    urlOpener: DefaultURLOpener())
  )
}
```

Note that if there are multiple registries, we'd want to configure them all in setupRegistries().

#### Unit testing code that uses a Registry

Developers writing unit tests that configure Floatation mocks can simply subclass [BuoyTestCase](https://github.com/dfed/Floatation/blob/master/BuoyTest/Sources/BuoyTestCase.swift) to automatically reset mocks to a new instance generated by `createMockShared()` before each test is run. Test classes that do not want to subclass `BuoyTestCase` can `@testable import Floatation` and manually call [BaseRegistry.🧪resetAllSharedInstances()](https://github.com/dfed/Floatation/blob/master/Floatation/Sources/Registry.swift#L116) before (or after, depending on preference) each test to reset configured shared instances.

#### Unit testing to ensure proper configuration

Floatation utilizes unit-tests (and therefore your CI) to ensure that your `Registry` classes do not vend `Mock` versions of themselves in a production build. Your app target will need a new unit test file that will call our setupRegistries() method, and then iterate over every known Registry to ensure it has a desired implementation set for it.

See the [AppDelegateTests](https://github.com/dfed/Floatation/blob/master/FloatationSampleApp/FloatationSampleAppTests/AppDelegateTests.swift#L19) file to see an example of a test to ensure that the app has set a desired implementation on every `Registry`. Floatation allows for the utilization the Objective-C runtime [to find every Registry-conforming class type in the application](https://github.com/dfed/Floatation/blob/master/Floatation/Sources/Registry.swift#L123) to ensure that every `Registry` is inspected.

#### Catching improper configuration during development

Developers who don't regularly run unit tests locally can be alerted that a `Registry` is missing a desired implementation at runtime. If your main app target has the Swift build flag `FLOATATION_SHOULD_ASSERT_WHEN_VENDING_MOCK_IMPLEMENTATION`, Floatation will trigger an assert if a `Mock` implementation is vended.

#### Handling advanced property lifecycles

Floatation already comes with a few built-in helper objects for handling advanced lifecycles of dependencies.

[Lazy](https://github.com/dfed/Floatation/blob/master/Floatation/Sources/Lazy.swift) is a wrapper for a singleton instance that is created at first access. This is best used for instances that might never be accessed.

[WeakLazy](https://github.com/dfed/Floatation/blob/master/Floatation/Sources/WeakLazy.swift) is a wrapper for a singleton instance that should live in memory only for the length that some consumers are interested in it. This is best used for instances that may take up a lot of memory (example: a database wrapper). `WeakLazy` vends a shared that must be retained by at least one object to stay alive. Once the last reference to the shared object is removed, the shared instance is deallocated. Accessing a `WeakLazy`’s `instance` again will create a new instance of that object.

#### Looking Under Registry's Hood

A [Registry](https://github.com/dfed/Floatation/blob/master/Floatation/Sources/Registry.swift#L6) is a `public typealias Registry = BaseRegistry & MockVendingRegistry`, where a BaseRegistry is a base class that lets us enforce that default implementations of a particular `Registry` is set only once, and a MockVendingRegistry is a protocol that enforces that a `Registry`-conforming class has a `createMockShared()` method.

Registry is extended to vend the shared static property that returns the default implementation of the registry if one has been set, or a memoized instance returned by `createMockShared()` if not.
