import SwiftUI

struct ContentView: View {
    @StateObject private var authVM = AuthViewModel()

    var body: some View {
        Group {
            if authVM.user != nil {
                MainTabView()
                    .environmentObject(authVM)
            } else {
                AuthView()
                    .environmentObject(authVM)
            }
        }
    }
}

