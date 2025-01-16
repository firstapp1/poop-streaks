import FirebaseFirestoreSwift

struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var phoneNumber: String
    var displayName: String
    var streaks: [String: Int]
    var pushToken: String?
}

