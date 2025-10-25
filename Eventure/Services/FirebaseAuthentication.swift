import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var password: String
    var username: String
}


