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


/** Focusable areas on registration screen, allowing for quick traversal of
 fields using the 'next' button on the iOS default keyboard. */
enum FocusableRegistrationField: Hashable {
    case emailField
    case passwordField
    case screenNameField
}


/** Allows client to sign-up and sign-in a new user, handling the necessary
 backend requests, such as saving user data and generating usernames, with
 helper class method or API calls thorugh the view model. Provides
 comprehensive error messages through banners. */
struct RegistrationView: View {
    
    /* MARK: Struct fields */
    
    @StateObject private var model = RegistrationViewModel()
    @FocusState private var focus: FocusableRegistrationField?
    @Environment(\.colorScheme) private var colorScheme
    
    /* MARK: View declaration */
    
    var body: some View {
        VStack {
            GroupBox {
                NavigationLink(destination: HomeView(currentUser: $model.registeredUser), tag: true, selection: $model.navigateToHome) { }

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
                Label(RegistrationConstant.welcomeMessage, systemImage: RegistrationConstant.welcomeIcon)
            }
            .padding()
        }
        .accentColor(Color(.label))
        .banner(data: $model.bannerData, show: $model.showErrorBanner)
        .navigationTitle(RegistrationConstant.navigationTitle)
    }
}


/** State and functional model for RegistrationView. */
class RegistrationViewModel: ObservableObject {
    
    /* MARK: Class fields */
    
    // Navigation fields
    @Published var navigateToHome: Bool? = false
    @Published var registeredUser: User = VerificationUtils.getNewUserModel(name: "", username: "", email: "")
    
    // Data fields
    @Published var nameField: String = ""
    @Published var passwordField: String = ""
    @Published var emailField: String = ""
    
    // UI state fields
    @Published var registerButtonState: ActionButtonState = RegistrationConstant.invalidRegisterButtonState
    @Published var registrationHasError: Bool = false
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showErrorBanner: Bool = false
    
    // Publisher fields
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
    
    /* MARK: Class methods */
    
    init() {
        emailIsValidPublisher
            .combineLatest(passwordIsValidPublisher, screenNameIsValidPublisher)
            .map { emailValid, passwordValid, screenNameIsValid in
                emailValid && passwordValid && screenNameIsValid
            }
            .map { fieldsValid -> ActionButtonState in
                if fieldsValid {
                    return RegistrationConstant.enabledRegisterButtonState
                }
                return RegistrationConstant.invalidRegisterButtonState
            }
            .assign(to: \.registerButtonState, on: self)
            .store(in: &cancellables)
    }
    
    func register() {
        registerButtonState = RegistrationConstant.loadingRegisterButtonState
        Auth.auth().createUser(withEmail: self.emailField, password: self.passwordField) { [weak self] _, error in
            guard error == nil else {
                self?.registerButtonState = RegistrationConstant.failedRegisterButtonState
                self?.showBannerWithErrorMessage(error!.localizedDescription)
                return
            }
            print("Created user")
            Auth.auth().signIn(withEmail: self!.emailField, password: self!.passwordField) { [weak self] _, error in
                guard error == nil else {
                    self?.registerButtonState = RegistrationConstant.failedRegisterButtonState
                    self?.showBannerWithErrorMessage(error!.localizedDescription)
                    return
                }
                print("Signed in user")
                VerificationUtils.availableUsernameFromName(self!.nameField) { generatedUsername, error in
                    guard error == nil else {
                        self?.registerButtonState = RegistrationConstant.failedRegisterButtonState
                        self?.showBannerWithErrorMessage(error!.localizedDescription)
                        return
                    }
                    let newUser = VerificationUtils.getNewUserModel(
                        name: self!.nameField,
                        username: generatedUsername!,
                        email: self!.emailField
                    )
                    print("Created user model")
                    APIHandler.uploadNewUser(newUser) { error in
                        guard error == nil else {
                            self?.registerButtonState = RegistrationConstant.failedRegisterButtonState
                            self?.showBannerWithErrorMessage(error!.localizedDescription)
                            APIHandler.attemptToDeleteCurrentUser()
                            return
                        }
                        print("Uploaded user to database")
                        self?.registerButtonState = RegistrationConstant.successRegisterButtonState
                        self?.registeredUser = newUser
                        self?.navigateToHome = true
                    }
                }
            }
        }
    }
    
    /* MARK: Helper methods */
    
    private func showBannerWithErrorMessage(_ message: String?) {
        guard let message = message else { return }
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
