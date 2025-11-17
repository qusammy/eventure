import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class SurveyViewModel: ObservableObject {
    
    // q1: location, q2–q4: preference answers
    @Published var question1: String = ""
    @Published var question2: String = ""
    @Published var question3: String = ""
    @Published var question4: String = ""
    @Published var errorMessage: String? = nil

    /// Data shape that gets stored in Firestore under "surveyResponses"
    var surveyData: [String: Any] {
        [
            "location": question1,
            "interests1": question2,
            "interests2": question3,
            "interests3": question4,
        ]
    }
    
    /// Save the current survey answers to Firestore for the logged-in user.
    func submitSurvey() {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user; cannot submit survey.")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(user.uid)
            .setData(["surveyResponses": surveyData], merge: true) { error in
                if let error = error {
                    print("Error saving survey: \(error.localizedDescription)")
                    self.errorMessage = "Error saving survey."
                } else {
                    print("Survey saved successfully!")
                    self.errorMessage = nil
                }
        }
    }
    
    /// Fetch survey answers from Firestore and populate question1–4.
    /// Calls `completion` once finished (success or fail).
    func fetchSurveyData(completion: (() -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user; cannot fetch survey.")
            completion?()
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).getDocument { document, error in
            defer { completion?() }  // always call completion at end
            
            if let error = error {
                print("Error fetching survey data: \(error.localizedDescription)")
                self.errorMessage = "Error fetching survey data."
                return
            }
            
            guard let surveyResponses = document?.get("surveyResponses") as? [String: Any] else {
                print("No survey data found for this user.")
                self.errorMessage = "You haven’t completed a survey yet."
                self.question1 = ""
                self.question2 = ""
                self.question3 = ""
                self.question4 = ""
                return
            }

            // Use the same keys we used when saving
            self.question1 = surveyResponses["location"] as? String ?? ""
            self.question2 = surveyResponses["interests1"] as? String ?? ""
            self.question3 = surveyResponses["interests2"] as? String ?? ""
            self.question4 = surveyResponses["interests3"] as? String ?? ""

            print("Survey data loaded successfully.")
            self.errorMessage = nil
        }
    }
}
