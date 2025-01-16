import SwiftUI
import AuthenticationServices
import CryptoKit
import FirebaseAuth

struct SignInWithAppleView: UIViewRepresentable {
    @EnvironmentObject var authVM: AuthViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleAuthorization), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}

    class Coordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
        var parent: SignInWithAppleView
        private var currentNonce: String?

        init(_ parent: SignInWithAppleView) {
            self.parent = parent
        }

        @objc func handleAuthorization() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            let nonce = randomNonceString()
            currentNonce = nonce
            request.nonce = sha256(nonce)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            // iOS 18 might have different APIs, but typically:
            UIApplication.shared.windows.first { $0.isKeyWindow }!
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if
                let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let nonce = currentNonce,
                let appleIDToken = appleIDCredential.identityToken,
                let idTokenString = String(data: appleIDToken, encoding: .utf8)
            {
                let credential = OAuthProvider.credential(
                    withProviderID: "apple.com",
                    idToken: idTokenString,
                    rawNonce: nonce
                )
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Sign in with Apple error: \(error.localizedDescription)")
                        return
                    }
                    self.parent.authVM.user = authResult?.user
                }
            }
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }

        // MARK: - Helper methods
        private func randomNonceString(length: Int = 32) -> String {
            // Implementation omitted for brevity
        }

        private func sha256(_ input: String) -> String {
            // Implementation omitted for brevity
        }
    }
}

