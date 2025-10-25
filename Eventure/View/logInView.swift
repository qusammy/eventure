//
//  logInView.swift
//  Eventure
//
//  Created by Maddy Quinn on 10/16/25.
//

import SwiftUI
import CoreMotion

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
    
    // Local variables
    
    @State var email: String = ""
    @State var password: String = ""

    // Motion variable
    
    @StateObject private var motion = MotionManager()

    var body: some View{
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
                
                // Forgot password button
                
                Button {
                    // action
                } label: {
                   Text("Forgot Password")
                        .foregroundStyle(Color("darkColor"))

                }.padding(.leading, 85)


                // Log in button
                
                Button {
                    // action
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width:225, height:50)
                            .foregroundStyle(Color("darkColor"))
                        Text("LOG IN")
                            .foregroundStyle(Color.white)
                    }
                }.padding(.top, 15)
                
                Text("OR")
                    .foregroundStyle(Color("darkColor"))
                    .padding(10)
                
                // Create new account button
                
                Button {
                    // action
                } label: {
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width:225, height:50)
                            .foregroundStyle(Color("darkColor"))
                        Text("CREATE ACCOUNT")
                            .foregroundStyle(Color.white)
                    }
                }
            }
        }
    }
}

#Preview {
    logInView()
}
