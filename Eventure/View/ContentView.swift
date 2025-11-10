import SwiftUI
import Firebase

struct ContentView: View {
    let apiKey = ProcessInfo.processInfo.environment["GOOGLE_API_KEY"]
    
var body: some View {
   
    NavigationStack{
        VStack{
            TabView{
                Tab("", systemImage: "gearshape.fill") {
                    settingsView()
                }
                Tab("", systemImage: "house.fill"){
                    resultsView()
                }
                Tab("", systemImage: "person.fill"){
                    logInView()
                }
            }
        }
    }
    }
}
#Preview {
    ContentView()
}
