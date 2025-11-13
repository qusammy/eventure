//
//  resultsView.swift
//  Eventure
//
//  Created by Maddy Quinn on 10/16/25.
//

import CoreMotion
import SwiftUI

struct resultsView: View {
    
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
                    .frame(width:300, height: 60)
            }
        }
        .onAppear {
                    surveyVM.fetchSurveyData()
        }
    }
}

#Preview {
    resultsView()
}
