//
//  logInView.swift
//  Eventure
//
//  Created by Maddy Quinn on 10/16/25.
//

import SwiftUI
import CoreMotion
import FirebaseAuth

// Motion class

class MotionManager: ObservableObject {
    private var motion = CMMotionManager()
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    

    init() {
        motion.deviceMotionUpdateInterval = 1.0 / 60.0  // 60 updates per second
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let data = data else { return }
            self?.pitch = data.attitude.pitch
            self?.roll = data.attitude.roll
        }
    }

    deinit {
        motion.stopDeviceMotionUpdates()
    }
}

struct logInView: View{
    
    // Log-in variables and vm
    
    @StateObject private var viewModel = AuthViewModel()
    
    @State private var showSignUpScreen = false
    @State private var showForgotPasswordScreen = false
    @State private var showSurveyScreen = false

    // Motion variable
    
    @StateObject private var motion = MotionManager()
        
    var body: some View{
        
        NavigationView{
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
                        
                        // Email text field
                        
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width:225, height:50)
                            .foregroundStyle(Color("textFieldColor"))
                            .overlay{
                                TextField("", text: $viewModel.email, prompt: Text("Email").foregroundColor(.white))
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                                    .foregroundStyle(Color.white)
                                    .padding(.leading, 5)
                                    .font(Font.custom("UbuntuSans-Regular", size: 18))
                            }
                        
                        // Password secure field
                        
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width:225, height:50)
                            .foregroundStyle(Color("textFieldColor"))
                            .overlay{
                                SecureField("", text: $viewModel.password, prompt: Text("Password").foregroundColor(.white))
                                    .disableAutocorrection(true)
                                    .textInputAutocapitalization(.never)
                                    .foregroundStyle(Color.white)
                                    .padding(.leading, 5)
                                    .font(Font.custom("UbuntuSans-Regular", size: 18))
                            }
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundStyle(Color("darkColor"))
                                .multilineTextAlignment(.center)
                                .font(Font.custom("UbuntuSans-Regular", size: 15))
                                .fontWeight(.medium)
                        }
                        
                        // Log in button
                        
                        Button {
                            Task {
                                await viewModel.signIn(email: viewModel.email, password: viewModel.password)
                            }
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width:225, height:50)
                                    .foregroundStyle(Color("darkColor"))
                                Text("Log in")
                                    .foregroundStyle(Color.white)
                                    .font(Font.custom("UbuntuSans-Regular", size: 18))
                                       
                                    
                            }
                        }
                        
                        // Forgot password button
                        
                        Button {
                            showForgotPasswordScreen.toggle()
                        } label: {
                            Text("Forgot Password?")
                                .foregroundStyle(Color("darkColor"))
                                .font(Font.custom("UbuntuSans-Regular", size: 15))
                                .fontWeight(.regular)
                            
                        }
                        
                        Text("OR")
                            .foregroundStyle(Color("darkColor"))
                            .padding(10)
                            .font(Font.custom("UbuntuSans-Regular", size: 18))
                            .fontWeight(.medium)

                        
                        // Create new account button
                        
                        Button {
                            showSignUpScreen.toggle()
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width:225, height:50)
                                    .foregroundStyle(Color("darkColor"))
                                Text("Create Account")
                                    .foregroundStyle(Color.white)
                                    .font(Font.custom("UbuntuSans-Regular", size: 18))
                        }
                    }
                }
            }
        }
        .onAppear{
            viewModel.getDisplayName()
        }
        .fullScreenCover(isPresented: $showForgotPasswordScreen){
            ResetPasswordView()
        }
        .fullScreenCover(isPresented: $showSignUpScreen, onDismiss: {
                    print("dismissed")
                }) {
                    signUpView()
                }
        }
}

#Preview {
    logInView()
}
