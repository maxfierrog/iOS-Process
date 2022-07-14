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
    @State private var didTapRegister: Bool? = nil
    
    /* View declaration */
    
    var body: some View {
        NavigationView {
            GroupBox {
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
                        .onSubmit {
                            model.loginUser()
                        }
                })
                
                ActionButton(state: $model.loginButtonState, onTap: {
                    model.loginUser()
                }, backgroundColor: colorScheme == .dark ? .indigo : .primary)
                
                Text("or")
                    .bold()
                    .font(.subheadline)
                
                NavigationLink(destination: RegistrationView(), tag: true, selection: $didTapRegister) {
                    ActionButton(state: $model.registerButtonState, onTap: {
                        didTapRegister = true
                    }, backgroundColor: colorScheme == .dark ? .brown : .primary)
                }
                
                Button {
                    model.sendPasswordResetEmail()
                } label: {
                    Text("Reset password")
                }
                .font(.footnote)
                .padding(.top, 5)
            } label: {
                Label("Welcome to Process!", systemImage: "person.fill")
            }
            .padding()
            .textFieldStyle(.plain)
            .navigationTitle("Login")
        }
    }
}


class LoginViewModel: ObservableObject {
    
    /* Class fields */
    
    @Published var passwordField: String = ""
    @Published var emailField: String = ""
    @Published var loginButtonState: ActionButtonState = ValidationUtils.invalidLoginButtonState
    @Published var registerButtonState: ActionButtonState = .enabled(title: "Register", systemImage: "list.bullet.rectangle")
    private var cancellables: Set<AnyCancellable> = []
    private var emailIsValidPublisher: AnyPublisher<Bool, Never> {
        $emailField
            .map { value in
                ValidationUtils.isValidEmail(value)
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
                    return ValidationUtils.enabledLoginButtonState
                }
                return ValidationUtils.invalidLoginButtonState
            }
            .assign(to: \.loginButtonState, on: self)
            .store(in: &cancellables)
    }
    
    func loginUser() {
        loginButtonState = ValidationUtils.loadingLoginButtonState
        Auth.auth().signIn(withEmail: emailField, password: passwordField) { [weak self] authResult, error in
            if (error != nil) {
                self?.loginButtonState = ValidationUtils.failedLoginButtonState
            } else {
                self?.loginButtonState = ValidationUtils.successLoginButtonState
                //FIXME: Show ProjectsView
            }
        }
    }
    
    func sendPasswordResetEmail() {
        guard ValidationUtils.isValidEmail(emailField) else {
            // FIXME: Show "invalid email" on banner
            return
        }
        Auth.auth().sendPasswordReset(withEmail: emailField) { error in
            if (error != nil) {
                // FIXME: Show error on banner
            } else {
                // FIXME: Show success baner
            }
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewInterfaceOrientation(.portrait)
    }
}
