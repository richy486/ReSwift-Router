//
//  SwiftFlowRouterTests.swift
//  SwiftFlowRouterTests
//
//  Created by Benjamin Encz on 12/2/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Quick
import Nimble
import ReactiveReSwift
@testable import ReactiveReSwiftRouter

class MockRoutable: Routable {

    var callsToPushRouteSegment: [(routeElement: RouteElementIdentifier, animated: Bool)] = []
    var callsToPopRouteSegment: [(routeElement: RouteElementIdentifier, animated: Bool)] = []
    var callsToChangeRouteSegment: [(
        from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        animated: Bool
    )] = []

    func pushRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        routeSpecificStateObserver: ObservableProperty<Any>?,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler
        ) -> Routable {

        callsToPushRouteSegment.append(
            (routeElement: routeElementIdentifier, animated: animated)
        )
        completionHandler()
        return MockRoutable()
    }

    func popRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        routeSpecificStateObserver: ObservableProperty<Any>?,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) {

        callsToPopRouteSegment.append(
            (routeElement: routeElementIdentifier, animated: animated)
        )
        completionHandler()
    }

    func changeRouteSegment(
        _ from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        routeSpecificStateObserver: ObservableProperty<Any>?,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler
        ) -> Routable {

        completionHandler()

        callsToChangeRouteSegment.append((from: from, to: to, animated: animated))

        return MockRoutable()
    }

}

struct FakeAppState {
    var navigationState = NavigationState()
}

func fakeReducer(action: Action, state: FakeAppState?) -> FakeAppState {
    return state ?? FakeAppState()
}

func appReducer(action: Action, state: FakeAppState?) -> FakeAppState {
    return FakeAppState(
        navigationState: NavigationReducer.handleAction(action, state: state?.navigationState)
    )
}

class TestStoreSubscriber<T> {
    var receivedStates: [T] = []
    var subscription: ((T) -> Void)!
    
    init() {
        subscription = { self.receivedStates.append($0) }
    }
}

class SwiftFlowRouterIntegrationTests: QuickSpec {

    override func spec() {

        describe("routing calls") {

            var store: Store<ObservableProperty<FakeAppState>>!
            
            enum Routes: RouteElement {
                case tabBarViewController
                case secondViewController
            }

            beforeEach {
                store = Store(reducer: appReducer, observable: ObservableProperty(FakeAppState()))
            }

            describe("setup") {

                it("does not request the root view controller when no route is provided") {

                    class FakeRootRoutable: Routable {
                        var called = false

                        func pushRouteSegment(_ routeElementIdentifier: RouteElementIdentifier,
                            completionHandler: RoutingCompletionHandler) -> Routable {
                                called = true
                                return MockRoutable()
                        }
                    }

                    let routable = FakeRootRoutable()
                    
                    let _ = Router<Any>(rootRoutable: routable)

                    expect(routable.called).to(beFalse())
                }

                it("requests the root with identifier when an initial route is provided") {
                    store.dispatch(
                        SetRouteAction([RouteIdentifiable(element: Routes.tabBarViewController)])
                    )

                    class FakeRootRoutable: Routable {
                        var calledWithIdentifier: (RouteElementIdentifier?) -> Void

                        init(calledWithIdentifier: @escaping (RouteElementIdentifier?) -> Void) {
                            self.calledWithIdentifier = calledWithIdentifier
                        }

                        func pushRouteSegment(_ routeElementIdentifier: RouteElementIdentifier,
                                              routeSpecificStateObserver: ObservableProperty<Any>?,
                                              animated: Bool,
                                              completionHandler: @escaping RoutingCompletionHandler) -> Routable {
                                calledWithIdentifier(routeElementIdentifier)

                                completionHandler()
                                return MockRoutable()
                        }

                    }

                    waitUntil(timeout: 2.0) { fullfill in
                        let rootRoutable = FakeRootRoutable { identifier in
                            guard let identifier = identifier else {
                                return
                            }
                            
                            if Routes.tabBarViewController == identifier.element{
                                fullfill()
                            }
                        }
                        
                        let router = Router<Any>(rootRoutable: rootRoutable)
                        store.observable.subscribe({ state in
                            router.newState(state: state.navigationState)
                        })
                    }
                }

                it("calls push on the root for a route with two elements") {
                    store.dispatch(
                        
                        SetRouteAction([RouteIdentifiable(element: Routes.tabBarViewController),
                                        RouteIdentifiable(element: Routes.secondViewController)])
                    )

                    class FakeChildRoutable: Routable {
                        var calledWithIdentifier: (RouteElementIdentifier?) -> Void

                        init(calledWithIdentifier: @escaping (RouteElementIdentifier?) -> Void) {
                            self.calledWithIdentifier = calledWithIdentifier
                        }

                        func pushRouteSegment(_ routeElementIdentifier: RouteElementIdentifier,
                                              routeSpecificStateObserver: ObservableProperty<Any>?,
                                              animated: Bool,
                                              completionHandler: @escaping RoutingCompletionHandler) -> Routable {
                                calledWithIdentifier(routeElementIdentifier)

                                completionHandler()
                                return MockRoutable()
                        }
                    }

                    waitUntil(timeout: 5.0) { completion in
                        let fakeChildRoutable = FakeChildRoutable() { identifier in
                            
                            guard let identifier = identifier else {
                                return
                            }
                            
                            if identifier.element == Routes.secondViewController {
                                completion()
                            }
                        }

                        class FakeRootRoutable: Routable {
                            let injectedRoutable: Routable

                            init(injectedRoutable: Routable) {
                                self.injectedRoutable = injectedRoutable
                            }

                            func pushRouteSegment(_ routeElementIdentifier: RouteElementIdentifier,
                                                  routeSpecificStateObserver: ObservableProperty<Any>?,
                                                  animated: Bool,
                                completionHandler: @escaping RoutingCompletionHandler) -> Routable {
                                    completionHandler()
                                    return injectedRoutable
                            }
                        }

                        let router = Router<Any>(rootRoutable: FakeRootRoutable(injectedRoutable: fakeChildRoutable))
                        store.observable.subscribe({ state in
                            router.newState(state: state.navigationState)
                        })
                    }
                }

            }

        }


        describe("route specific data") {

            var store: Store<ObservableProperty<FakeAppState>>!
            
            enum Routes: RouteElement {
                case part1
                case part2
            }

            beforeEach {
                store = Store(reducer: appReducer, observable: ObservableProperty(FakeAppState()))
                
                store.observable.subscribe({ state in
                    print("state update: \(state)")
                })
            }

            context("when setting route specific data") {
                
                let route = [RouteIdentifiable(element: Routes.part1), RouteIdentifiable(element: Routes.part1)]
                
                beforeEach {
                    store.dispatch(SetRouteSpecificData(route: route,
                                                        data: "UserID_10"))
                }

                it("allows accessing the data when providing the expected type") {

                    let data: String? = store.observable.value.navigationState.getRouteSpecificStateObserver(route)?.value as? String

                    expect(data).toEventually(equal("UserID_10"))
                }
            }
        }

        describe("configuring animated/unanimated navigation") {

            var store: Store<ObservableProperty<FakeAppState>>!
            var mockRoutable: MockRoutable!
            var router: Router<FakeAppState>!
            
            enum Routes: RouteElement {
                case someRoute
            }

            beforeEach {
                store = Store(reducer: appReducer, observable: ObservableProperty(FakeAppState()))
                mockRoutable = MockRoutable()
                
                router = Router(rootRoutable: mockRoutable)
                store.observable.subscribe({ state in
                    router.newState(state: state.navigationState)
                })
                _ = router
            }

            context("when dispatching an animated route change") {
                beforeEach {
                    store.dispatch(SetRouteAction([RouteIdentifiable(element: Routes.someRoute)], animated: true))
                }

                it("calls routables asking for an animated presentation") {
                    expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beTrue())
                }
            }

            context("when dispatching an unanimated route change") {
                beforeEach {
                    store.dispatch(SetRouteAction([RouteIdentifiable(element: Routes.someRoute)], animated: false))
                }

                it("calls routables asking for an animated presentation") {
                    expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beFalse())
                }
            }

            context("when dispatching a default route change") {
                beforeEach {
                    store.dispatch(SetRouteAction([RouteIdentifiable(element: Routes.someRoute)]))
                }

                it("calls routables asking for an animated presentation") {
                    expect(mockRoutable.callsToPushRouteSegment.last?.animated).toEventually(beTrue())
                }
            }
        }
    }
}
