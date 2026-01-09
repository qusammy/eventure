// View shown when user clicks button to create a new account

import SwiftUI
import CoreMotion

struct ResetPasswordView: View {
    
    @StateObject private var motion = MotionManager()
    @StateObject private var viewModel = AuthViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @State private var sentEmail: Bool = false
    @State private var errorText: Bool = false

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
                .opacity(0.40)
            VStack{
                Image("eventureLogo")
                    .resizable()
                    .frame(width:300, height: 150)
                Text("Please enter the email to your\naccount to reset its password")
                    .foregroundStyle(Color("darkColor"))
                    .padding(10)
                    .font(Font.custom("DidactGothic-Regular", size: 18))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                RoundedRectangle(cornerRadius: 15)
                    .frame(width:225, height:50)
                    .foregroundStyle(Color("textFieldColor"))
                    .overlay{
                        TextField("", text: $viewModel.email, prompt: Text("Email").foregroundColor(.white))
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .foregroundStyle(Color.white)
                            .padding(.leading, 5)
                            .font(Font.custom("DidactGothic-Regular", size: 18))
                    }
                
                if (sentEmail == true) {
                    Text("Check your email for a reset link.\nIf it's not there, try your spam folder.")
                        .foregroundStyle(Color("darkColor"))
                        .padding(10)
                        .font(Font.custom("DidactGothic-Regular", size: 18))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
                if (errorText == true){
                    Text("Please enter a valid email.")
                        .foregroundStyle(Color("darkColor"))
                        .padding(10)
                        .font(Font.custom("DidactGothic-Regular", size: 18))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
               
                Button {
                    viewModel.resetPassword(email: viewModel.email)
                    if(viewModel.email.isEmpty){
                        errorText = true
                        sentEmail = false
                    } else
                    {
                        sentEmail = true
                        errorText = false
                    }
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 25)
                            .frame(width:225, height:50)
                            .foregroundStyle(Color("darkColor"))
                        Text("Reset password")
                            .foregroundStyle(Color.white)
                            .font(Font.custom("DidactGothic-Regular", size: 18))
                    }
                }
                Button {
                    dismiss()
                } label: {
                    Text("Back to login")
                        .foregroundStyle(Color("darkColor"))
                        .font(Font.custom("DidactGothic-Regular", size: 15))
                        .fontWeight(.medium)
                    
                }
            }
        }
    }
}

#Preview {
    ResetPasswordView()
}
