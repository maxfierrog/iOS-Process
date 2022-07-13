//
//  LoginView.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI
import ActionButton
import Combine
import FirebaseAuth
import SwiftUIX
import CoreAudio

enum FocusableLoginField: Hashable {
    case emailField
    case passwordField
}

struct LoginView: View {
    
    @StateObject private var model = LoginViewModel()
    @FocusState private var focus: FocusableLoginField?
    
    @State private var didTapRegister: Bool? = nil
    
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
                            model.login()
                        }
                })
                
                ActionButton(state: $model.loginButtonState, onTap: {
                    model.login()
                }, backgroundColor: .primary)
                
                Text("or")
                    .bold()
                    .font(.subheadline)
                
                NavigationLink(destination: RegistrationView(), tag: true, selection: $didTapRegister) {
                    ActionButton(state: $model.registerButtonState, onTap: {
                        didTapRegister = true
                    }, backgroundColor: .primary)
                }
            } label: {
                Label("Welcome!", systemImage: "person.fill")
            }
            .padding()
            .textFieldStyle(.plain)
            .navigationTitle("Login")
        }
    }
}

class LoginViewModel: ObservableObject {
    
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
    
    func login() {
        loginButtonState = ValidationUtils.loadingLoginButtonState
        Auth.auth().signIn(withEmail: emailField, password: passwordField) { [weak self] authResult, error in
            if (error != nil) {
                self?.loginButtonState = ValidationUtils.failedLoginButtonState
            } else {
                self?.loginButtonState = ValidationUtils.successLoginButtonState
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
