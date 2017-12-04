//
//  RouteElement.swift
//  ReactiveReSwiftRouter
//
//  Created by Richard Adem on 6/15/17.
//  Copyright © 2017 Benjamin Encz. All rights reserved.
//

import Foundation

public protocol RouteElement {}

public struct RouteIdentifiable: Equatable {
    public let element: RouteElement
    public let identifier: String
    
    public init(element: RouteElement) {
        self.element = element
        self.identifier = UUID().uuidString
    }
    
    public static func ==(lhs: RouteIdentifiable, rhs: RouteIdentifiable) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Array where Element == RouteIdentifiable {
    public mutating func append(_ newElement: RouteElement) {
        append(RouteIdentifiable(element: newElement))
    }

    public func joined(separator: String) -> String {
        return reduce("") { (result, element) -> String in
            var result = result
            if result.count > 0 {
                result.append(separator)
            }
            result.append("\(element.element)-\(element.identifier)")
            return result
        }
    }
}

public func == (lhs: RouteElement, rhs: RouteElement) -> Bool {
    
    if Mirror(reflecting: lhs).displayStyle == .enum &&
        Mirror(reflecting: rhs).displayStyle == .enum {

        return String(reflecting: lhs) == String(reflecting: rhs) &&
            type(of: lhs) == type(of: rhs)
    }
    
    return false
}
public func != (lhs: RouteElement, rhs: RouteElement) -> Bool {
    return !(lhs == rhs)
}
