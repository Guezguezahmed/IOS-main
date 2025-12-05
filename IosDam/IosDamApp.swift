import SwiftUI

@main
struct IosDamApp: App {
    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.bool(forKey: "rememberMe"),
               let _ = UserDefaults.standard.string(forKey: "userToken") {
                // Token existant et rememberMe activé → HomeView
                HomeView()
            } else {
                
                    SplashView()
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true)
                        .edgesIgnoringSafeArea(.all)
              
               
            }
        }
    }
}
