//
//  LoginViewModel.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/9/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import CryptoKit
import AuthenticationServices
import GoogleSignIn

class LoginViewModel: ObservableObject {
    // MARK: View Properties
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    
    // MARK: Error Properties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: App Log Status
    @AppStorage("log_status") var logStatus: Bool = false
    
    // MARK: Apple Sign in Properties
    @Published var nonce: String = ""
    
    //MARK: Loading indicator
    @Published var isLoading: Bool = false
    
    
    // MARK: Firebase API's Phone Auth
    func getOTPCode(){
        print("getOTPCode")
        UIApplication.shared.closeKeyboard()
        Task{
            do{
                // MARK: Disable it when testing with Real Device
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                
                let code = try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(mobileNo)", uiDelegate: nil)
                await MainActor.run(body: {
                    CLIENT_CODE = code
                    // MARK: Enabling OTP Field When It's Success
                    withAnimation(.easeInOut){showOTPField = true}
                })
            }catch{
                await handleError(error: error)
            }
        }
    }
    
    
    func verifyOTPCode(){
        print("verifyOTPCode")
        UIApplication.shared.closeKeyboard()
        Task{
            await MainActor.run {self.isLoading = true}
            do{
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_CODE, verificationCode: otpCode)
                
                let authResult = try await Auth.auth().signIn(with: credential)
                
                // MARK: User Logged in Successfully
                print("Success!")
                //判断是否首次等录
                let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                
                if isNewUser {
                    // Create a profile in Firestore for new users
                    try await StorageManager.shared.createProfile(user: authResult.user)
                }
                await MainActor.run {
                    withAnimation(.easeInOut) { logStatus = true }
                    UserDefaults.standard.set(true, forKey: "log_status")
                    NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
                }
            }catch{
                await handleError(error: error)
            }
            await MainActor.run { self.isLoading = false }
        }
    }
    
    // MARK: Handling Error
    func handleError(error: Error)async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
    // MARK: Apple Sign in API
    func appleAuthenticate(credential: ASAuthorizationAppleIDCredential){
        
        // getting Token....
        guard let token = credential.identityToken else{
            print("error with firebase")
            
            return
        }
        
        // Token String...
        guard let tokenString = String(data: token, encoding: .utf8) else{
            print("error with Token")
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString,rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { (result, err) in
            
            if let error = err{
                print(error.localizedDescription)
                return
            }
            
            // User Successfully Logged Into Firebase...
            print("Logged In Success")
            //判断是否首次登录
            withAnimation(.easeInOut) {
                self.logStatus = true
                UserDefaults.standard.set(true, forKey: "log_status")
                NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
            }
            
            
        }
    }
    
    // MARK: Logging Google User into Firebase
    func logGoogleUser(user: GIDGoogleUser){
        Task{
            await MainActor.run { self.isLoading = true }
            do{
                guard let idToken = user.idToken else{return}
                let accesToken = user.accessToken
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accesToken.tokenString)
                
                let authResult = try await Auth.auth().signIn(with: credential)
                
                print("Sucess Google!")
                let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                
                if isNewUser {
                    // Create a profile in Firestore for new users
                    try await StorageManager.shared.createProfile(user: authResult.user)
                }
                await MainActor.run {
                    withAnimation(.easeInOut) { logStatus = true }
                    UserDefaults.standard.set(true, forKey: "log_status")
                    NotificationCenter.default.post(name: .loginStatusChanged, object: nil)
                }
            }catch{
                await handleError(error: error)
            }
            await MainActor.run { self.isLoading = false }
        }
    }
    
}

// MARK: Extensions
extension UIApplication{
    func closeKeyboard(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Root Controller
    func rootController()->UIViewController{
        guard let window = connectedScenes.first as? UIWindowScene else{return .init()}
        guard let viewcontroller = window.windows.last?.rootViewController else{return .init()}
        
        return viewcontroller
    }
}


// MARK: Apple Sign in Helpers
func sha256(_ input: String) -> String {
 let inputData = Data(input.utf8)
 let hashedData = SHA256.hash(data: inputData)
 let hashString = hashedData.compactMap {
   return String(format: "%02x", $0)
 }.joined()

 return hashString
}

func randomNonceString(length: Int = 32) -> String {
 precondition(length > 0)
 let charset: Array<Character> =
     Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
 var result = ""
 var remainingLength = length

 while remainingLength > 0 {
   let randoms: [UInt8] = (0 ..< 16).map { _ in
     var random: UInt8 = 0
     let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
     if errorCode != errSecSuccess {
       fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
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

