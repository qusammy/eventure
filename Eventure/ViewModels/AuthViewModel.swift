import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

@MainActor

class AuthViewModel: ObservableObject {
    
    @Published var user: FirebaseAuth.User? = nil
    @Published var isLoading = false
    @Published var createdNewAccount = false
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    
    @Published var errorMessage: String?
    
    let db = Firestore.firestore()
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
               self?.user = user
               if let user = user {
                   // Optionally load display name when signed in
                   self?.getDisplayName()
               } else {
                   self?.username = ""
               }
           }
    }

    func signUp(email: String, password: String, username: String) async {
        guard !email.isEmpty, !password.isEmpty else{
            return
        }
        guard password.count >= 6 else {
               DispatchQueue.main.async {
                   self.errorMessage = "Password must be at least 6 characters long."
               }
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
            createdNewAccount = true
        } catch let error as NSError {
            DispatchQueue.main.async {
                if let authError = AuthErrorCode(_bridgedNSError: error) {
                    switch authError.code {
                    case .emailAlreadyInUse:
                        self.errorMessage = "An account already exists for that email."
                    case .invalidEmail:
                        self.errorMessage = "Please enter a valid email address."
                    case .weakPassword:
                        self.errorMessage = "Password must be at least 6 characters long."
                    default:
                        self.errorMessage = "Sign-up failed. Please try again."
                    }
                } else {
                    self.errorMessage = "An unknown error occurred."
                }
            }
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
            self.errorMessage = "User email or password\nis incorrect."
        }
        isLoading = false
    }

    func signInWithGoogle() {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            guard let rootViewController = UIApplication.shared
                .connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?
                .windows
                .first?
                .rootViewController else {
                return
            }

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    print("Google sign-in error:", error.localizedDescription)
                    return
                }

                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString
                else { return }

                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: user.accessToken.tokenString
                )

                Auth.auth().signIn(with: credential) { _, error in
                    if let error = error {
                        print("Firebase Google auth error:", error.localizedDescription)
                    }
                }
            }
        }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
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
