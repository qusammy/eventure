import SwiftUI

struct settingsView: View {
    
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ZStack{
            LiquidChromeView(
                baseColor: [0.28, 0.63, 0.63],
                speed: 0.4,
                amplitude: 0.25,
                freqX: 4,
                freqY: 3
            )
            .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: 25)
                .padding(10)
                .foregroundStyle(Color.white)
                .opacity(0.80)
            VStack{
                Image("eventureLogo")
                    .resizable()
                    .frame(width:300, height: 60)
                
                List{
        
                    Text("About")
                        .foregroundStyle(Color("darkColor"))
                        .font(Font.custom("UbuntuSans-Regular", size: 18))
                        .fontWeight(.medium)
                        .listRowBackground(Color.clear)

                    Text("Privacy Policy")
                        .foregroundStyle(Color("darkColor"))
                        .font(Font.custom("UbuntuSans-Regular", size: 18))
                        .fontWeight(.medium)
                        .listRowBackground(Color.clear)
                    
                    Text("Take Survey")
                        .foregroundStyle(Color("darkColor"))
                        .font(Font.custom("UbuntuSans-Regular", size: 18))
                        .fontWeight(.medium)
                        .listRowBackground(Color.clear)

                    Text("Log out")
                        .foregroundStyle(Color("darkColor"))
                        .font(Font.custom("UbuntuSans-Regular", size: 18))
                        .fontWeight(.medium)
                        .listRowBackground(Color.clear)
                        .buttonStyle(BorderlessButtonStyle())
                        .onTapGesture {
                            viewModel.signOut()
                        }

                   

                }
                .scrollContentBackground(.hidden)
                .frame(maxHeight:500)
                
            }
        }
    }
}

#Preview {
    settingsView()
}
