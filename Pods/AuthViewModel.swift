//
//  AuthViewModel.swift
//  poop-streaks
//
//  Created by Emmet Reilly on 1/16/25.
//


import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        self.user = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func verifyPhoneNumber(phoneNumber: String, completion: @escaping (String?) -> Void) {
        isLoading = true
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(nil)
                return
            }
            completion(verificationID)
        }
    }

    func signInWithVerificationCode(
        verificationID: String,
        verificationCode: String,
        completion: @escaping (Bool) -> Void
    ) {
        isLoading = true
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            self.user = authResult?.user
            completion(true)
        }
    }
}
