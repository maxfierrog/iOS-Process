//
//  Registration.swift
//  process
//
//  Created by Maximo Fierro on 7/11/22.
//

import SwiftUI
import ActionButton
import Combine
import FirebaseAuth


enum FocusableRegistrationField: Hashable {
    case emailField
    case passwordField
    case screenNameField
    case usernameField
}


struct RegistrationView: View {
    
    /* Struct fields */
    
    @StateObject private var model = RegistrationViewModel()
    @FocusState private var focus: FocusableRegistrationField?
    @Environment(\.colorScheme) private var colorScheme
    
    /* View declaration */
    
    var body: some View {
        NavigationView {
            VStack {
                GroupBox {
                    VStack (alignment: .center, spacing: 10, content: {
                        Image("register-image")
                            .resizable()
                            .scaledToFit()
                            .padding(.bottom, 10)
                            .padding(.top, 15)
                        
                        TextField(text: $model.usernameField, prompt: Text("Username")) {
                            Text("Unique username")
                        }
                        .padding(.bottom, 10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .submitLabel(.next)
                        .focused($focus, equals: .usernameField)
                        .onSubmit {
                            focus = .screenNameField
                        }
                        
                        TextField(text: $model.screenNameField, prompt: Text("Name")) {
                            Text("Screen name")
                        }
                        .padding(.bottom, 10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .submitLabel(.next)
                        .focused($focus, equals: .screenNameField)
                        .onSubmit {
                            focus = .emailField
                        }
                        
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
                    
                    ActionButton(state: $model.registerButtonState, onTap: {
                        model.register()
                    }, backgroundColor: colorScheme == .dark ? .brown : .primary)
                } label: {
                    Label("We'll just need a few things...", systemImage: "list.bullet.rectangle.fill")
                }
                .padding()
                .navigationTitle("Register")
            }
            
            Spacer()
        }
        .accentColor(Color(.label))
        .banner(data: $model.bannerData, show: $model.showErrorBanner)
    }
}


class RegistrationViewModel: ObservableObject {
    
    /* Class fields */
    
    @Published var usernameField: String = ""
    @Published var screenNameField: String = ""
    @Published var passwordField: String = ""
    @Published var emailField: String = ""
    
    @Published var registerButtonState: ActionButtonState = ValidationUtils.invalidRegisterButtonState
    @Published var registrationHasError: Bool = false
    
    @Published var showErrorBanner:Bool = false
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    
    private var cancellables: Set<AnyCancellable> = []
    private var emailIsValidPublisher: AnyPublisher<Bool, Never> {
        $emailField
            .map { value in
                ValidationUtils.isValidEmail(value)
            }
            .eraseToAnyPublisher()
    }
    private var usernameIsValidPublisher: AnyPublisher<Bool, Never> {
        $usernameField
            .map { value in
                !value.isEmpty
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
    private var screenNameIsValidPublisher: AnyPublisher<Bool, Never> {
        $screenNameField
            .map { value in
                !value.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    /* Class methods */
    
    init() {
        emailIsValidPublisher
            .combineLatest(passwordIsValidPublisher, screenNameIsValidPublisher, usernameIsValidPublisher)
            .map { emailValid, passwordValid, screenNameIsValid, usernameIsValid in
                emailValid && passwordValid && screenNameIsValid && usernameIsValid
            }
            .map { fieldsValid -> ActionButtonState in
                if fieldsValid {
                    return ValidationUtils.enabledRegisterButtonState
                }
                return ValidationUtils.invalidRegisterButtonState
            }
            .assign(to: \.registerButtonState, on: self)
            .store(in: &cancellables)
    }
    
    func register() {
        registerButtonState = ValidationUtils.loadingRegisterButtonState
        APIHandler.matchUsernameQuery(usernameField) { querySnapshot, error in
            if (error == nil && querySnapshot!.documents.isEmpty && ValidationUtils.isValidEmail(self.emailField)) {
                Auth.auth().createUser(withEmail: self.emailField, password: self.passwordField) { [weak self] authResult, error in
                    if (error == nil) {
                        let newUser = User(username: self!.usernameField, screenName: self!.screenNameField)
                        APIHandler.uploadNewUser(newUser) { error in
                            if (error == nil) {
                                self!.registerButtonState = ValidationUtils.successLoginButtonState
                                // TODO: Navigate to projects view
                            } else {
                                self!.registerButtonState = ValidationUtils.failedRegisterButtonState
                                self!.setBannerToGenericError(error!.localizedDescription)
                            }
                        }
                    } else {
                        self!.registerButtonState = ValidationUtils.failedRegisterButtonState
                        self!.setBannerToGenericError(error!.localizedDescription)
                    }
                }
            } else if (!querySnapshot!.documents.isEmpty) {
                self.registerButtonState = ValidationUtils.failedRegisterButtonState
                self.setBannerToGenericError("Sorry, that username is already being used by someone else.")
            } else {
                self.registerButtonState = ValidationUtils.failedRegisterButtonState
                self.setBannerToGenericError(error!.localizedDescription)
            }
        }
    }
    
    private func setBannerToGenericError(_ message: String) {
        bannerData.title = "Error"
        bannerData.detail = message
        bannerData.type = .Error
        showErrorBanner = true
    }
}


struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .previewInterfaceOrientation(.portrait)
    }
}
