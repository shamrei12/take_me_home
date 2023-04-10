//
//  EnterViewController.swift
//  TakeMeHome
//
//  Created by Алексей Шамрей on 7.02.23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import CryptoKit
import AuthenticationServices
import FirebaseDatabase
//import GoogleSignIn

class EnterViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    fileprivate var currentNonce: String?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func enterWithApple(_ sender: UIButton) {
        startSignInWithAppleFlow()
    }
    
    
    @IBAction func enterWithGoogle(_ sender: UIButton) {
//        var userName = ""
//        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//
//        // Create Google Sign In configuration object.
//        let config = GIDConfiguration(clientID: clientID)
//        GIDSignIn.sharedInstance.configuration = config
//
//
//        // Start the sign in flow!
//        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] (result, error) in
//            guard error == nil else {
//                return
//            }
//
//            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
//                return
//            }
//            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
//                return
//            }
//
//            // Получаем имя пользователя
//            let name = user.profile?.name
//            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
//            Auth.auth().signIn(with: credential) { result, error in
//
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                }
//
//                guard let uid = result?.user.uid else {
//                    return
//                }
//                if name == "" {
//                    userName = "Аноним"
//                }
//                let ref = Database.database().reference().child("users").child(uid)
//                ref.setValue(["name": name])
//            }
//        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension EnterViewController: ASAuthorizationControllerDelegate {
    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        //        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let uid = authResult?.user.uid else {
                    return
                }
                var name = appleIDCredential.fullName?.givenName ?? "Аноним"
                // Save the user's ID and name to the database.
                let ref = Database.database().reference().child("users").child(uid)
                ref.setValue(["name": name])
            }
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
}
