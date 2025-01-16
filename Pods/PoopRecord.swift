import FirebaseFirestoreSwift

struct PoopRecord: Identifiable, Codable {
    @DocumentID var id: String?
    var length: Double
    var timestamp: Date
    var senderID: String
    var recipientIDs: [String]
    var acknowledged: [String: Bool]
}

