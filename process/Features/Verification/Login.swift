//
//  Login.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI
import ActionButton
import Combine
import FirebaseAuth


enum FocusableLoginField: Hashable {
    case emailField
    case passwordField
}


struct LoginView: View {
    
    /* Struct fields */
    
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var model = LoginViewModel()
    @FocusState private var focus: FocusableLoginField?
    
    /* View declaration */
    
    var body: some View {
        NavigationView {
            GroupBox {
                NavigationLink(destination: RegistrationView(), tag: true, selection: $model.navigateToRegister) { }
                NavigationLink(destination: HomeView(), tag: true, selection: $model.navigateToHome) { }
                
                VStack (alignment: .center, spacing: 10, content: {
                    Image("login-image")
                        .resizable()
                        .scaledToFit()
                    
                    EmailField(title: "Email", text: $model.emailField)
                        .padding(.bottom, 10)
                        .submitLabel(.next)
                        .focused($focus, equals: .emailField)
                        .onSubmit {
                            focus = .passwordField
                        }
                    
                    PasswordField(title: "Password", text: $model.passwordField)
                        .padding(.bottom, 20)
                        .focused($focus, equals: .passwordField)
                        .submitLabel(.go)
                })
                
                ActionButton(state: $model.loginButtonState, onTap: {
                    model.loginUser()
                }, backgroundColor: colorScheme == .dark ? .indigo : .primary)
                
                Text("or")
                    .bold()
                    .font(.subheadline)
                
                ActionButton(state: $model.registerButtonState, onTap: {
                    model.didTapRegister()
                }, backgroundColor: colorScheme == .dark ? .brown : .primary)
                
                Button {
                    model.sendPasswordResetEmail()
                } label: {
                    Text("Forgot password")
                        .underline()
                }
                .font(.footnote)
                .padding(.top, 5)
            } label: {
                Label("Welcome to Process!", systemImage: "person.fill")
            }
            .padding()
            .navigationTitle("Login")
        }
        .accentColor(Color(.label))
        .banner(data: $model.bannerData, show: $model.showErrorBanner)
    }
}


class LoginViewModel: ObservableObject {
    
    /* Class fields */
    
    @Published var navigateToHome: Bool? = false
    
    @Published var passwordField: String = ""
    @Published var emailField: String = ""
    @Published var navigateToRegister: Bool? = nil
    
    @Published var loginButtonState: ActionButtonState = VerificationUtils.invalidLoginButtonState
    @Published var registerButtonState: ActionButtonState = .enabled(title: "Register", systemImage: "list.bullet.rectangle")
    
    @Published var showErrorBanner: Bool = false
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    
    private var cancellables: Set<AnyCancellable> = []
    private var emailIsValidPublisher: AnyPublisher<Bool, Never> {
        $emailField
            .map { value in
                VerificationUtils.isValidEmail(value)
            }
            .eraseToAnyPublisher()
    }
    private var passwordIsValidPublisher: AnyPublisher<Bool, Never> {
        $passwordField
            .map { value in
                !value.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    /* Methods */
    
    init() {
        emailIsValidPublisher
            .combineLatest(passwordIsValidPublisher)
            .map { emailValid, passwordValid in
                emailValid && passwordValid
            }
            .map { fieldsValid -> ActionButtonState in
                if fieldsValid {
                    return VerificationUtils.enabledLoginButtonState
                }
                return VerificationUtils.invalidLoginButtonState
            }
            .assign(to: \.loginButtonState, on: self)
            .store(in: &cancellables)
    }
    
    func loginUser() {
        loginButtonState = VerificationUtils.loadingLoginButtonState
        Auth.auth().signIn(withEmail: emailField, password: passwordField) { [weak self] authResult, error in
            if (error != nil) {
                self!.loginButtonState = VerificationUtils.failedLoginButtonState
            } else {
                self!.loginButtonState = VerificationUtils.successLoginButtonState
                self!.navigateToHome = true
            }
        }
    }
    
    func sendPasswordResetEmail() {
        guard VerificationUtils.isValidEmail(emailField) else {
            setBannerToGenericError("Please enter a valid email address.")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: emailField) { error in
            self.bannerData.title = "Email sent"
            self.bannerData.detail = "We have sent a recovery link to the account associated with that email address, if there is one."
            self.bannerData.type = .Info
            self.showErrorBanner = true
        }
    }
    
    func didTapRegister() {
        showErrorBanner = false
        navigateToRegister = true
    }
    
    private func setBannerToGenericError(_ message: String) {
        bannerData.title = "Error"
        bannerData.detail = message
        bannerData.type = .Error
        showErrorBanner = true
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewInterfaceOrientation(.portrait)
    }
}
