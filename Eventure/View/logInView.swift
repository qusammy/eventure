//
//  logInView.swift
//  Eventure
//
//  Created by Maddy Quinn on 10/16/25.
//

import SwiftUI

struct logInView: View{
    
    @State var email: String = ""

    var body: some View{
        ZStack{
            Image("kayakPicture")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.white)
                .opacity(0.4)
            VStack{
                Image("eventureLogo")
                    .resizable()
                    .frame(width:250, height: 60)
            }
        }
    }
}

#Preview {
    logInView()
}
