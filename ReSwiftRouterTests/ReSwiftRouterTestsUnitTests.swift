//
//  SwiftFlowRouterUnitTests.swift
//  Meet
//
//  Created by Benjamin Encz on 12/2/15.
//  Copyright © 2015 DigiTales. All rights reserved.
//

import Quick
import Nimble

import ReactiveReSwift
@testable import ReactiveReSwiftRouter

class ReSwiftRouterUnitTests: QuickSpec {

    // Used as test app state
    struct AppState {}

    override func spec() {
        describe("routing calls") {

            enum Routes: RouteElement {
                case tabBarViewControllerIdentifier
                case counterViewControllerIdentifier
                case statsViewControllerIdentifier
                case infoViewControllerIdentifier
            }

            it("calculates transitions from an empty route to a multi segment route") {
                let oldRoute: Route = []
                let newRoute = [RouteIdentifiable(element: Routes.tabBarViewControllerIdentifier),
                                RouteIdentifiable(element: Routes.statsViewControllerIdentifier)]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 0
                            && segmentToBePushed.element == Routes.tabBarViewControllerIdentifier {
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePushed.element == Routes.statsViewControllerIdentifier {
                            action2Correct = true
                        }
                }

                expect(routingActions).to(haveCount(2))
                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
            }

            it("generates a Change action on the last common subroute") {
                let commonSubroute = RouteIdentifiable(element: Routes.tabBarViewControllerIdentifier)
                let oldRoute = [commonSubroute,
                                RouteIdentifiable(element: Routes.counterViewControllerIdentifier)]
                let newRoute = [commonSubroute,
                                RouteIdentifiable(element: Routes.statsViewControllerIdentifier)]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var controllerIndex: Int?
                var toBeReplaced: RouteElementIdentifier?
                var new: RouteElementIdentifier?

                if case let RoutingActions.change(responsibleControllerIndex, controllerToBeReplaced, newController) = routingActions.first! {
                    controllerIndex = responsibleControllerIndex
                    toBeReplaced = controllerToBeReplaced
                    new = newController
                }
                
                

                expect(routingActions).to(haveCount(1))
                expect(controllerIndex).to(equal(1))
                expect(Routes.counterViewControllerIdentifier).to(equal(Routes.counterViewControllerIdentifier))
                
                guard let toBeReplacedElement = toBeReplaced?.element, let newElement = new?.element else {
                    fail()
                    return
                }
                expect(toBeReplacedElement == Routes.counterViewControllerIdentifier).to(beTrue())
                expect(newElement == Routes.statsViewControllerIdentifier).to(beTrue())
            }

            it("generates a Change action on the last common subroute, also for routes of different length") {
                let commonSubroute = RouteIdentifiable(element: Routes.tabBarViewControllerIdentifier)
                let oldRoute = [commonSubroute,
                                RouteIdentifiable(element: Routes.counterViewControllerIdentifier)]
                let newRoute = [commonSubroute,
                                RouteIdentifiable(element: Routes.statsViewControllerIdentifier),
                                RouteIdentifiable(element: Routes.infoViewControllerIdentifier)]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.change(responsibleRoutableIndex, segmentToBeReplaced,
                    newSegment)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 1
                            && segmentToBeReplaced.element == Routes.counterViewControllerIdentifier
                            && newSegment.element == Routes.statsViewControllerIdentifier{
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePushed.element == Routes.infoViewControllerIdentifier {

                                action2Correct = true
                        }
                }

                expect(routingActions).to(haveCount(2))
                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
            }

            it("generates a Change action on root when root element changes") {
                let oldRoute = [RouteIdentifiable(element: Routes.tabBarViewControllerIdentifier)]
                let newRoute = [RouteIdentifiable(element: Routes.statsViewControllerIdentifier)]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var controllerIndex: Int?
                var toBeReplaced: RouteElementIdentifier?
                var new: RouteElementIdentifier?

                if case let RoutingActions.change(responsibleControllerIndex,
                    controllerToBeReplaced,
                    newController) = routingActions.first! {
                        controllerIndex = responsibleControllerIndex
                        toBeReplaced = controllerToBeReplaced
                        new = newController
                }

                expect(routingActions).to(haveCount(1))
                expect(controllerIndex).to(equal(0))

                guard let toBeReplacedElement = toBeReplaced?.element, let newElement = new?.element else {
                    fail()
                    return
                }

                expect(toBeReplacedElement == Routes.tabBarViewControllerIdentifier).to(beTrue())
                expect(newElement == Routes.statsViewControllerIdentifier).to(beTrue())
            }

            it("calculates no actions for transition from empty route to empty route") {
                let oldRoute: Route = []
                let newRoute: Route = []

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                expect(routingActions).to(haveCount(0))
            }

            it("calculates no actions for transitions between identical, non-empty routes") {
                let routeElementTabBar = RouteIdentifiable(element: Routes.tabBarViewControllerIdentifier)
                let routeElementStatus = RouteIdentifiable(element: Routes.statsViewControllerIdentifier)
                
                let oldRoute = [routeElementTabBar, routeElementStatus]
                let newRoute = [routeElementTabBar, routeElementStatus]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                expect(routingActions).to(haveCount(0))
            }

            it("calculates transitions with multiple pops") {

                let commonSubroute = RouteIdentifiable(element: Routes.tabBarViewControllerIdentifier)
                
                let oldRoute = [commonSubroute,
                                RouteIdentifiable(element: Routes.statsViewControllerIdentifier),
                                RouteIdentifiable(element: Routes.counterViewControllerIdentifier)]
                let newRoute = [commonSubroute]
                
                

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.pop(responsibleRoutableIndex, segmentToBePopped)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePopped.element == Routes.counterViewControllerIdentifier {
                                action1Correct = true
                            }
                }

                if case let RoutingActions.pop(responsibleRoutableIndex, segmentToBePopped)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePopped.element == Routes.statsViewControllerIdentifier {
                                action2Correct = true
                        }
                }

                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
                expect(routingActions).to(haveCount(2))
            }

            it("calculates transitions with multiple pushes") {
                let commonSubroute = RouteIdentifiable(element: Routes.tabBarViewControllerIdentifier)
                
                let oldRoute = [commonSubroute]
                let newRoute = [commonSubroute,
                                RouteIdentifiable(element: Routes.statsViewControllerIdentifier),
                                RouteIdentifiable(element: Routes.counterViewControllerIdentifier)]

                let routingActions = Router<AppState>.routingActionsForTransitionFrom(oldRoute,
                    newRoute: newRoute)

                var action1Correct: Bool?
                var action2Correct: Bool?

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[0] {

                        if responsibleRoutableIndex == 1
                            && segmentToBePushed.element == Routes.statsViewControllerIdentifier {
                                action1Correct = true
                        }
                }

                if case let RoutingActions.push(responsibleRoutableIndex, segmentToBePushed)
                    = routingActions[1] {

                        if responsibleRoutableIndex == 2
                            && segmentToBePushed.element == Routes.counterViewControllerIdentifier {
                                action2Correct = true
                        }
                }

                expect(action1Correct).to(beTrue())
                expect(action2Correct).to(beTrue())
                expect(routingActions).to(haveCount(2))
            }

        }

    }

}
