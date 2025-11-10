import SwiftUI

@main
struct iOS_FEApp: App {
    @StateObject private var authViewModel = AuthViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                BottomBar()
                    .environmentObject(authViewModel)
            } else {
                AuthView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
