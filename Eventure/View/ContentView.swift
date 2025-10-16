import SwiftUI

struct ContentView: View {
var body: some View {
    NavigationStack{
        VStack{
            TabView{
                Tab("", systemImage: "person.fill") {
                    homeView()
                }
                Tab("", systemImage: "house.fill"){
                    resultsView()
                }
                Tab("", systemImage: "gearshape.fill"){
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
