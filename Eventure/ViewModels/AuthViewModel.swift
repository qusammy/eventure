import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

@MainActor

class AuthViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User? = nil
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var createdNewAccount = false
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    
    let db = Firestore.firestore()
    
    init() {
        self.user = Auth.auth().currentUser
    }

    func signUp(email: String, password: String, username: String) async {
        guard !email.isEmpty, !password.isEmpty else{
            return
        }
        isLoading = true
        errorMessage = ""
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            try await db.collection("users").document(result.user.uid).setData([
                           "email": email,
                           "username": username
                       ], merge: true)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    func resetPassword(email: String){
            Auth.auth().sendPasswordReset(withEmail: email){ error in
                if error != nil {
                    print("error")
                    return
                }
                print("success")
            }
        }
    func getDisplayName() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(userID).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.get("username") as? String
                self.username = dataDescription ?? ""
            } else {
                print("Document does not exist")
            }
        }
    }

}
