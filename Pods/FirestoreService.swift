//
//  FirestoreService.swift
//  poop-streaks
//
//  Created by Emmet Reilly on 1/16/25.
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class FirestoreService: ObservableObject {
    let db = Firestore.firestore()

    // MARK: - Users
    func fetchCurrentUser(completion: @escaping (UserModel?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user: \(error)")
                completion(nil)
                return
            }
            let user = try? snapshot?.data(as: UserModel.self)
            completion(user)
        }
    }

    func createUser(user: UserModel, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        do {
            try db.collection("users").document(uid).setData(from: user)
            completion(true)
        } catch {
            print("Error creating user: \(error)")
            completion(false)
        }
    }

    // MARK: - Friends
    func fetchFriends(completion: @escaping ([FriendModel]?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        db.collection("users").document(uid).collection("friends").getDocuments { snap, error in
            if let error = error {
                print("Error fetching friends: \(error)")
                completion(nil)
                return
            }
            let friends = snap?.documents.compactMap { doc in
                try? doc.data(as: FriendModel.self)
            }
            completion(friends)
        }
    }

    func addFriend(friend: FriendModel, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        do {
            try db.collection("users").document(uid).collection("friends").addDocument(from: friend)
            completion(true)
        } catch {
            print("Error adding friend: \(error)")
            completion(false)
        }
    }

    func removeFriend(friendID: String, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        db.collection("users").document(uid).collection("friends").document(friendID).delete { error in
            if let error = error {
                print("Error removing friend: \(error)")
                completion(false)
                return
            }
            completion(true)
        }
    }

    // MARK: - Poop Records
    func sendPoop(poop: PoopRecord, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("poops").addDocument(from: poop)
            completion(true)
        } catch {
            print("Error sending poop: \(error)")
            completion(false)
        }
    }

    func fetchPoops(for userID: String, completion: @escaping ([PoopRecord]?) -> Void) {
        db.collection("poops")
            .whereField("recipientIDs", arrayContains: userID)
            .getDocuments { snap, error in
                if let error = error {
                    print("Error fetching poops: \(error)")
                    completion(nil)
                    return
                }
                let poops = snap?.documents.compactMap { doc in
                    try? doc.data(as: PoopRecord.self)
                }
                completion(poops)
            }
    }

    // Example: Updating streak counts
    func updateStreak(for userID: String, friendID: String, increment: Bool = true) {
        let userRef = db.collection("users").document(userID)
        userRef.updateData([
            "streaks.\(friendID)": FieldValue.increment(Int64(increment ? 1 : -1))
        ]) { error in
            if let error = error {
                print("Error updating streak: \(error)")
            }
        }
    }
}
