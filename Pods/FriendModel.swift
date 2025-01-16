//
//  FriendModel.swift
//  poop-streaks
//
//  Created by Emmet Reilly on 1/16/25.
//


import FirebaseFirestoreSwift

struct FriendModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var phoneNumber: String
    var lastPoopDate: Date?
    var streakCount: Int
}
