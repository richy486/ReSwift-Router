//
//  Routable.swift
//  Meet
//
//  Created by Benjamin Encz on 12/3/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import ReactiveReSwift

public typealias RoutingCompletionHandler = () -> Void

public protocol RouteSpecificStateObserver {
    
    typealias ValueType = Any
}

public protocol Routable {
    
    func pushRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        routeSpecificStateObserver: RouteSpecificStateObserver?,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable

    func popRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        routeSpecificStateObserver: RouteSpecificStateObserver?,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler)

    func changeRouteSegment(
        _ from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        routeSpecificStateObserver: RouteSpecificStateObserver?,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable

}

extension Routable {

    public func pushRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        routeSpecificStateObserver: RouteSpecificStateObserver?,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }

    public func popRouteSegment(
        _ routeElementIdentifier: RouteElementIdentifier,
        routeSpecificStateObserver: RouteSpecificStateObserver?,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }

    public func changeRouteSegment(
        _ from: RouteElementIdentifier,
        to: RouteElementIdentifier,
        routeSpecificStateObserver: RouteSpecificStateObserver?,
        animated: Bool,
        completionHandler: @escaping RoutingCompletionHandler) -> Routable {
            fatalError("This routable cannot change segments. You have not implemented it.")
    }

}
