import FirebaseDatabase
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class SurveyViewModel: ObservableObject {
    
    @Published var question1: String = ""
    @Published var question2: String = ""
    @Published var question3: String = ""
    @Published var question4: String = ""
    @Published var errorMessage: String? = nil

    var surveyData: [String: Any] {
        [
            "location": question1,
            "interests1": question2,
            "interests2": question3,
            "interests3": question4,
        ]
    }
    
    func submitSurvey() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(user.uid)
            .setData(["surveyResponses": surveyData], merge: true) { error in
                if let error = error {
                    print("Error saving survey: \(error.localizedDescription)")
                } else {
                    print("Survey saved successfully!")
                }
        }
    }
    func fetchSurveyData() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).getDocument { document, error in
            if let error = error {
                print("Error fetching survey data: \(error.localizedDescription)")
                return
            }
            
            guard let data = document?.data(),
                  let surveyResponses = data["surveyResponses"] as? [String: Any] else {
                print("No survey data found for this user.")
                return
            }
            
            if let surveyResponses = document?.get("surveyResponses") as? [String: Any] {
                        self.question1 = surveyResponses["question1"] as? String ?? ""
                        self.question2 = surveyResponses["question2"] as? String ?? ""
                        self.question3 = surveyResponses["question3"] as? String ?? ""
                        print("Survey data loaded successfully.")
                        self.errorMessage = ""

                    } else {
                        self.errorMessage = "You haven’t completed a survey yet."
                        print("No surveyResponses field found — likely a new user.")
                        self.question1 = ""
                        self.question2 = ""
                        self.question3 = ""
                    }
        }
    }
}

struct SurveyViewStyleMC: View {
        @State var question: String
        @State var answer1: String
        @State var answer2: String
        @State var answer3: String
        @State var answer4: String
        
        @Binding var selectedAnswer: String
        
        @State private var answer1Checked = false
        @State private var answer2Checked = false
        @State private var answer3Checked = false
        @State private var answer4Checked = false
        
        var body: some View {
            VStack {
                Text(question)
                    .foregroundStyle(Color("darkColor"))
                    .font(Font.custom("UbuntuSans-Regular", size: 20))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: 400)
                
                ForEach([(answer1, $answer1Checked),
                         (answer2, $answer2Checked),
                         (answer3, $answer3Checked),
                         (answer4, $answer4Checked)], id: \.0) { answer, isChecked in
                    Button {
                        answer1Checked = (answer == answer1)
                        answer2Checked = (answer == answer2)
                        answer3Checked = (answer == answer3)
                        answer4Checked = (answer == answer4)
                        selectedAnswer = answer // <-- Save to ViewModel
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundStyle(isChecked.wrappedValue ? Color("AccentColor") : Color.white)
                                .opacity(0.80)
                                .frame(maxWidth: 300, minHeight: 50)
                            Text(answer)
                                .foregroundStyle(isChecked.wrappedValue ? Color.white : Color("darkColor"))
                                .font(Font.custom("UbuntuSans-Regular", size: 18))
                                .fontWeight(.medium)
                    }
                }
                .padding(2.5)
            }
        }
    }
}

struct SurveyViewStyleFRQ: View{
    
    @State var question: String
    @Binding var userAnswer: String
    
    var body: some View {
        VStack{
            Text(question)
                .foregroundStyle(Color("darkColor"))
                .font(Font.custom("UbuntuSans-Regular", size: 20))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: 400)
            RoundedRectangle(cornerRadius: 15)
                .frame(maxWidth:300, minHeight:50)
                .foregroundStyle(Color.white)
                .opacity(0.80)
                .overlay{
                    TextField("", text: $userAnswer, prompt: Text("City, state, or zip code").foregroundColor(Color("darkColor")))
                        .foregroundStyle(Color("darkColor"))
                        .padding(.leading, 5)
                        .font(Font.custom("UbuntuSans-Regular", size: 18))
                        .fontWeight(.medium)
                }
        }
    }
}
