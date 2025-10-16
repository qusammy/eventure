import CoreMotion
import SwiftUI

struct homeView: View {
    var body: some View {
        VStack {
            ZStack{
                Image("kayakPicture")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width:100, height:100)
            }
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    homeView()
}
