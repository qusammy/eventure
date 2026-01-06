import SwiftUI
import CoreMotion

struct settingsView: View {
    
    @StateObject private var viewModel = AuthViewModel()
    @StateObject private var surveyVM = SurveyViewModel()
    @StateObject private var motion = MotionManager()

    @State private var showSurveyScreen = false

    var body: some View {
        ZStack{
            Image("kayakPicture")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fill)
                .frame(width:1000, height:1000)
                .ignoresSafeArea() .offset(x: motion.roll * 50, y: motion.pitch * 50)
                .animation(.easeOut(duration: 0.1), value: motion.roll)
                .blur(radius: 4)
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.white)
                .opacity(0.50)
            VStack{
                Image("eventureLogo")
                    .resizable()
                    .frame(width:300, height: 150)
                Text("Welcome, \(viewModel.username)! Eventure uses AI to\ngenerate events in your area tailored\nto your interests. Take the\nsurvey below to get started.")
                    .foregroundStyle(Color("darkColor"))
                    .font(Font.custom("UbuntuSans-Regular", size: 18))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(40)
                
                Button {
                    showSurveyScreen.toggle()
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width:225, height:50)
                            .foregroundStyle(Color("darkColor"))
                        Text("Take survey")
                            .foregroundStyle(Color.white)
                            .font(Font.custom("UbuntuSans-Regular", size: 18))
                    }
                }
                
                Text("OR")
                    .foregroundStyle(Color("darkColor"))
                    .font(Font.custom("UbuntuSans-Regular", size: 18))
                    .fontWeight(.regular)
                
                Button {
                    viewModel.signOut()
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width:225, height:50)
                            .foregroundStyle(Color("darkColor"))
                        Text("Log out")
                            .foregroundStyle(Color.white)
                            .font(Font.custom("UbuntuSans-Regular", size: 18))
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showSurveyScreen){
            SurveyView()
        }
    }
}

#Preview {
    settingsView()
}
