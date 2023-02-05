//
//  SimpleInvestApp.swift
//  SimpleInvest
//
//  Created by Bogdan Vasilinchuk on 05.02.2023.
//

import SwiftUI
import Firebase


@main
struct SimpleInvestApp: App {
    init() {
        FirebaseApp.configure()
    }
    @StateObject var authViewModel = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            SplashView().environmentObject(authViewModel)
            
        }
    }
}
