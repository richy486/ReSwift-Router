//
//  NavigationState.swift
//  Meet
//
//  Created by Benjamin Encz on 11/11/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import ReactiveReSwift

public typealias RouteElementIdentifier = RouteIdentifiable
public typealias Route = [RouteElementIdentifier]

/// A `Hashable` and `Equatable` presentation of a route.
/// Can be used to check two routes for equality.
public struct RouteHash: Hashable {
    let routeHash: String

    public init(route: Route) {
        self.routeHash = route.joined(separator: "/")
    }

    public var hashValue: Int { return self.routeHash.hashValue }
}

public func == (lhs: RouteHash, rhs: RouteHash) -> Bool {
    return lhs.routeHash == rhs.routeHash
}

public struct NavigationState {
    public init() {}

    public var route: Route = []
    public var routeSpecificStateObservers: [RouteHash: RouteSpecificStateObserver] = [:]
    
    var changeRouteAnimated: Bool = true
}

extension NavigationState {
    public func getRouteSpecificStateObserver(_ route: Route) -> RouteSpecificStateObserver? {
        let hash = RouteHash(route: route)
        
        return self.routeSpecificStateObservers[hash]
    }
}

public protocol HasNavigationState {
    var navigationState: NavigationState { get set }
}
