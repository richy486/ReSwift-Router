//
//  RouteHashTests.swift
//  ReSwiftRouter
//
//  Created by Benji Encz on 7/16/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import ReactiveReSwiftRouter
import Quick
import Nimble

enum RouteHashTestsRoutes: RouteElement {
    case part1
    case part2
    case part3
    case part4
}

class RouteHashTests: QuickSpec {

    override func spec() {

        describe("when two route hashs are initialized with the same elements") {

            var routeHash1: RouteHash!
            var routeHash2: RouteHash!

            beforeEach {
                
                let routePart1 = RouteIdentifiable(element: RouteHashTestsRoutes.part1)
                let routePart2 = RouteIdentifiable(element: RouteHashTestsRoutes.part2)
                
                routeHash1 = RouteHash(route: [routePart1, routePart2])
                routeHash2 = RouteHash(route: [routePart1, routePart2])
            }

            it("both hashs are considered equal") {
                expect(routeHash1).to(equal(routeHash2))
            }

        }

        describe("when two route hashs are initialized with different elements") {

            var routeHash1: RouteHash!
            var routeHash2: RouteHash!

            beforeEach {
                routeHash1 = RouteHash(route: [RouteIdentifiable(element: RouteHashTestsRoutes.part1),
                                               RouteIdentifiable(element: RouteHashTestsRoutes.part2)])
                
                routeHash2 = RouteHash(route: [RouteIdentifiable(element: RouteHashTestsRoutes.part3),
                                               RouteIdentifiable(element: RouteHashTestsRoutes.part4)])
            }

            it("they are considered unequal") {
                expect(routeHash1).toNot(equal(routeHash2))
            }

        }

    }

}
