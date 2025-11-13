import SwiftUI
import Firebase

struct ContentView: View {
    let apiKey = ProcessInfo.processInfo.environment["GOOGLE_API_KEY"]
    
    @StateObject private var viewModel = AuthViewModel()
    
var body: some View {
    if viewModel.user == nil {
        logInView()
    }
    else {
        NavigationStack{
            VStack{
                TabView{
                    Tab("", systemImage: "person.fill") {
                        settingsView()
                    }
                    Tab("", systemImage: "house.fill"){
                        resultsView()
                    }
                }
            }
        }
    }
    }
}
#Preview {
    ContentView()
}
