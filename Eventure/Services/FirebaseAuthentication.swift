import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var password: String
    var username: String
}


