import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct SurveyView: View {
    
    @StateObject private var surveyVM = SurveyViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Firebase variables
    let db = Firestore.firestore()
    
    var body: some View {
        ZStack{
            Image("kayakPicture")
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fill)
                .frame(width:1000, height:1000)
                .blur(radius: 4)
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(.white)
                .opacity(0.50)
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    Button {
                        dismiss()
                    } label: {
                        Text("Exit survey")
                            .foregroundStyle(Color("darkColor"))
                            .font(Font.custom("UbuntuSans-Regular", size: 18))
                    }
                    .offset(x:-135)
                    .padding(10)
                    
                    Text("Start Survey Below")
                        .foregroundStyle(Color("darkColor"))
                        .font(Font.custom("UbuntuSans-Regular", size: 25))
                        .fontWeight(.medium)
                    
                    SurveyViewStyleFRQ(
                        question: "Where are you located?",
                        userAnswer: $surveyVM.question1
                    )
                    
                    SurveyViewStyleMC(
                        question: "Which of the following do you prefer to do the most?",
                        answer1: "Going to concerts",
                        answer2: "Watching sports",
                        answer3: "Attending museums",
                        answer4: "Watching movies",
                        selectedAnswer: $surveyVM.question2
                    )
                    
                    SurveyViewStyleMC(
                        question: "What would you identify yourself most closely with?",
                        answer1: "Extrovert",
                        answer2: "Introvert",
                        answer3: "Both",
                        answer4: "Neither",
                        selectedAnswer: $surveyVM.question3
                    )

                    SurveyViewStyleMC(
                        question: "Which of the following venues do you prefer the most?",
                        answer1: "Indoor",
                        answer2: "Outdoor",
                        answer3: "Mix of indoor & outdoor",
                        answer4: "Online",
                        selectedAnswer: $surveyVM.question4
                    )
                    
                    Button {
                        surveyVM.submitSurvey()
                        dismiss()
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 25)
                                .frame(width:300, height:50)
                                .foregroundStyle(Color("darkColor"))
                            Text("Submit survey to AI")
                                .foregroundStyle(Color.white)
                                .font(Font.custom("UbuntuSans-Regular", size: 18))
                                .fontWeight(.medium)
                        }
                    }
                    .padding(10)
                    
                }
                .padding(.top, 125)
                .padding(.bottom, 125)
                
            }
        }
    }
}

#Preview {
    SurveyView()
}
