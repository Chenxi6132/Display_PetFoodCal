//
//  Login.swift
//  PetFoodCalculator
//
//  Created by Chenxi Xu on 7/8/24.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import Firebase
import FirebaseAuth


struct Login: View {
    @StateObject var loginModel: LoginViewModel = .init()
    
    var body: some View {
            
            VStack(spacing: 10){
                if let appIcon = UIImage(named: "AppIcon") {
                    Image(uiImage: appIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.indigo)
                        .padding(.top, -60)
                } else {
                    // Optionally handle the case where the image is not found
                    Image(systemName: "photo") // Example fallback using SF Symbol
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.indigo)
                        .padding(.top, -60)
                }
                
                
                (Text("Welcome,")
                    .foregroundColor(.primary) +
                 Text("\nLogin to continue")
                    .foregroundColor(.secondary)
                )
                .font(.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 30)
                .padding(.top, 20)
                
                
                CustomTextField(hint: "+1 6505551111", text: $loginModel.mobileNo)
                    .disabled(loginModel.showOTPField)
                    .opacity(loginModel.showOTPField ? 0.4 : 1)
                    .overlay(alignment: .trailing) {
                        Button("Change") {
                            withAnimation(.easeInOut) {
                                loginModel.showOTPField = false
                                loginModel.otpCode = ""
                                loginModel.CLIENT_CODE = ""
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(loginModel.showOTPField ? 1 : 0)
                        .padding(.trailing, 15)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 50)
                
                HStack(spacing: 10) {
                    CustomTextField(hint: "OTP Code", text: $loginModel.otpCode)
                        .disabled(!loginModel.showOTPField)
                        .opacity(!loginModel.showOTPField ? 0.4 : 1)
                        .padding(.horizontal, 0)
                    
                    Button(action: loginModel.showOTPField ? loginModel.verifyOTPCode : loginModel.getOTPCode) {
                        Text(loginModel.showOTPField ? "Verify Code" : "Get Code")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 30)
                
                Text("(OR)")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                
                HStack(spacing: 8){
                    // MARK: Custom Apple Sign in Button
                    CustomButton()
                        .overlay {
                            SignInWithAppleButton(
                                onRequest: { request in
                                loginModel.nonce = randomNonceString()
                                request.requestedScopes = [.email, .fullName]
                                request.nonce = sha256(loginModel.nonce)
                            }, onCompletion: { (result) in
                                switch result{
                                case .success(let user):
                                    print("success")
                                    guard let credential = user.credential as? ASAuthorizationAppleIDCredential else{
                                        print("error with firebase")
                                        return
                                    }
                                    loginModel.appleAuthenticate(credential: credential)
                                case.failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                                )
                            .signInWithAppleButtonStyle(.white)
                            .frame(height: 55)
                            .blendMode(.overlay)
                        }
                        .clipped()
                    
                    // MARK: Custom Google Sign in Button
                    CustomButton(isGoogle: true)
                        .overlay {
                            // MARK: We Have Native Google Sign in Button
                            // It's Simple to Integrate Now
                            GoogleSignInButton{
                                Task{
                                    do{
                                        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.rootController())
                                        
                                        loginModel.logGoogleUser(user: result.user)
                                        
                                    }catch{
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            .blendMode(.overlay)
                        }
                        .clipped()
                }
                .padding(.leading,0)
                .frame(maxWidth: .infinity)
            
                if loginModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                }
            }
        .alert(loginModel.errorMessage, isPresented: $loginModel.showError) {
        }
    }
    
    
    
    @ViewBuilder
    func CustomButton(isGoogle: Bool = false)->some View{
        HStack{
            Group{
                if isGoogle{
                    Image(uiImage: UIImage(named: "Google")!)
                        .resizable()
                    //.renderingMode(.template)
                }else{
                    Image(systemName: "applelogo")
                        .resizable()
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .frame(height: 45)
            
            Text("\(isGoogle ? "Google" : "Apple") Sign in")
                .font(.callout)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal,15)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
