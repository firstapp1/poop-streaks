//
//  AuthView.swift
//  poop-streaks
//
//  Created by Emmet Reilly on 1/16/25.
//


import SwiftUI

struct AuthView: View {
    @StateObject private var authVM = AuthViewModel()
    @State private var phoneNumber = ""
    @State private var verificationID: String?
    @State private var showingVerification = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to poop-streaks")
                    .font(.largeTitle)
                    .padding()

                // Phone Auth
                VStack(spacing: 15) {
                    TextField("Phone Number (+1...)", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)

                    Button("Send Verification Code") {
                        authVM.verifyPhoneNumber(phoneNumber: phoneNumber) { verID in
                            if let verID = verID {
                                self.verificationID = verID
                                self.showingVerification = true
                            }
                        }
                    }
                    .disabled(authVM.isLoading || phoneNumber.isEmpty)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()

                // Sign in with Apple
                SignInWithAppleView()

                Spacer()
            }
            .navigationTitle("Login")
            .sheet(isPresented: $showingVerification) {
                VerificationCodeView(
                    authVM: authVM,
                    verificationID: verificationID ?? ""
                )
            }
            .alert(item: $authVM.errorMessage) { msg in
                Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct VerificationCodeView: View {
    @ObservedObject var authVM: AuthViewModel
    var verificationID: String
    @Environment(\.presentationMode) var presentationMode
    @State private var code = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter Verification Code")
                    .font(.headline)

                TextField("Code", text: $code)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Button("Verify Code") {
                    authVM.signInWithVerificationCode(
                        verificationID: verificationID,
                        verificationCode: code
                    ) { success in
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .disabled(authVM.isLoading || code.isEmpty)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()
            }
            .padding()
            .navigationTitle("Verify")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
