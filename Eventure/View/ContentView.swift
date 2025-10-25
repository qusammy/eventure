import SwiftUI

struct ContentView: View {
var body: some View {
    NavigationStack{
        VStack{
            TabView{
                Tab("", systemImage: "gearshape.fill") {
                    homeView()
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
