// View shown when user clicks button to create a new account

import SwiftUI

struct signUpView: View {
    
    // Auth VM and sign up variables
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    
    @State var createdNewAccount: Bool = false
    
    @StateObject private var viewModel = AuthViewModel()

    @StateObject private var motion = MotionManager()
    @Environment(\.dismiss) private var dismiss

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
                    .frame(width:300, height: 60)
                    .padding(.bottom, 50)
                
                Text("Enter creditentials below to \ncreate a new account")
                    .foregroundStyle(Color("darkColor"))
                    .padding(.top, 10)
                    .padding(.bottom, 25)
                    .multilineTextAlignment(.center)
                
                // Email text field
                
                RoundedRectangle(cornerRadius: 15)
                    .frame(width:225, height:50)
                    .foregroundStyle(Color("textFieldColor"))
                    .overlay{
                        TextField("", text: $email, prompt: Text("Email").foregroundColor(.white))
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .foregroundStyle(Color.white)
                            .padding(.leading, 5)
                    }
                
                // username text field
                
                RoundedRectangle(cornerRadius: 15)
                    .frame(width:225, height:50)
                    .foregroundStyle(Color("textFieldColor"))
                    .overlay{
                        TextField("", text: $username, prompt: Text("Display name").foregroundColor(.white))
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .foregroundStyle(Color.white)
                            .padding(.leading, 5)
                    }
                
                // Password secure field
                
                RoundedRectangle(cornerRadius: 15)
                    .frame(width:225, height:50)
                    .foregroundStyle(Color("textFieldColor"))
                    .overlay{
                        SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white))
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .foregroundStyle(Color.white)
                            .padding(.leading, 5)
                    }
                
                // Create new account button
                
                Button {
                    Task {
                        createdNewAccount = true
                        await viewModel.signUp(email: email, password: password, username: username)
                        await viewModel.signIn(email: email, password: password)
                        dismiss()
                        
                    }
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width:225, height:50)
                            .foregroundStyle(Color("darkColor"))
                        Text("CREATE ACCOUNT")
                            .foregroundStyle(Color.white)
                    }
                }.padding(.top, 50)
                
                // Dismiss view
                
                Button {
                    Task {
                        dismiss()
                    }
                } label: {
                    Text("Back to login")
                        .foregroundStyle(Color("darkColor"))
                        .padding(10)
                }
            }
        }
    }
}

#Preview {
    signUpView()
}
