//
//  FinancyApp.swift
//  FinancyWatch Extension
//
//  Created by Jakub Pazik on 18/09/2021.
//  Copyright © 2021 Jakub Pazik. All rights reserved.
//

import SwiftUI

@main
struct FinancyApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
