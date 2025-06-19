//
//  NavigationRouter.swift
//  Snapcook-CoreML
//
//  Created by Naela Fauzul Muna on 18/06/25.
//

//import SwiftUI
//
//enum Route: Hashable {
//    case customCamera
//}
//
//class NavigationRouter: ObservableObject {
//    @Published var path = NavigationPath()
//
//    func navigate(to route: Route) {
//        path.append(route)
//    }
//
//    func pop() {
//        path.removeLast()
//    }
//
//    func popToRoot() {
//        path.removeLast(path.count)
//    }
//}
//
//extension NavigationRouter {
//    static func destinations(path: Binding<NavigationPath>) -> some ViewModifier {
//        return NavigationDestinationModifier(path: path)
//    }
//
//    private struct NavigationDestinationModifier: ViewModifier {
//        @Binding var path: NavigationPath
//
//        func body(content: Content) -> some View {
//            content.navigationDestination(for: Route.self) { route in
//                switch route {
//                case .customCamera:
//                    ContentView()
//                        .navigationBarBackButtonHidden(true)
//                }
//            }
//        }
//    }
//}
