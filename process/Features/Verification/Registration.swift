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
}


struct RegistrationView: View {
    
    /* Struct fields */
    
    @StateObject private var model = RegistrationViewModel()
    @FocusState private var focus: FocusableRegistrationField?
    @Environment(\.colorScheme) private var colorScheme
    
    /* View declaration */
    
    var body: some View {
        VStack {
            GroupBox {
                NavigationLink(destination: HomeView(), tag: true, selection: $model.navigateToHome) { }

                VStack (alignment: .center, spacing: 10, content: {
                    Image("register-image")
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 10)
                        .padding(.top, 15)
                    
                    TextField(text: $model.nameField, prompt: Text("Name")) {
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
        }
        .accentColor(Color(.label))
        .banner(data: $model.bannerData, show: $model.showErrorBanner)
        .navigationTitle("Register")
    }
}


class RegistrationViewModel: ObservableObject {
    
    /* Class fields */
    
    @Published var navigateToHome: Bool? = false
    
    @Published var nameField: String = ""
    @Published var passwordField: String = ""
    @Published var emailField: String = ""
    
    @Published var registerButtonState: ActionButtonState = VerificationUtils.invalidRegisterButtonState
    @Published var registrationHasError: Bool = false
    
    @Published var showErrorBanner:Bool = false
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
    private var screenNameIsValidPublisher: AnyPublisher<Bool, Never> {
        $nameField
            .map { value in
                !value.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    /* Class methods */
    
    init() {
        emailIsValidPublisher
            .combineLatest(passwordIsValidPublisher, screenNameIsValidPublisher)
            .map { emailValid, passwordValid, screenNameIsValid in
                emailValid && passwordValid && screenNameIsValid
            }
            .map { fieldsValid -> ActionButtonState in
                if fieldsValid {
                    return VerificationUtils.enabledRegisterButtonState
                }
                return VerificationUtils.invalidRegisterButtonState
            }
            .assign(to: \.registerButtonState, on: self)
            .store(in: &cancellables)
    }
    
    func register() {
        registerButtonState = VerificationUtils.loadingRegisterButtonState
        Auth.auth().createUser(withEmail: self.emailField, password: self.passwordField) { [weak self] authResult, error in
            if (error == nil) {
                Auth.auth().signIn(withEmail: self!.emailField, password: self!.passwordField) { [weak self] authResult, error in
                    if (error == nil) {
                        let newUser = User(name: self!.nameField)
                        APIHandler.uploadNewUser(newUser) { error in
                            if (error == nil) {
                                self!.registerButtonState = VerificationUtils.successLoginButtonState
                                self!.navigateToHome = true
                            } else {
                                self!.registerButtonState = VerificationUtils.failedRegisterButtonState
                                self!.setBannerToGenericError(error!.localizedDescription)
                            }
                        }
                    } else {
                        self!.registerButtonState = VerificationUtils.failedRegisterButtonState
                        self!.setBannerToGenericError(error!.localizedDescription)
                    }
                }
            } else {
                self!.registerButtonState = VerificationUtils.failedRegisterButtonState
                self!.setBannerToGenericError(error!.localizedDescription)
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
