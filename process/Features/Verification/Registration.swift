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
    
    @StateObject var model: RegistrationViewModel
    @FocusState private var focus: FocusableRegistrationField?
    @Environment(\.colorScheme) private var colorScheme
    
    /* MARK: Registration view */
    
    var body: some View {
        VStack {
            GroupBox {
                VStack (alignment: .center, spacing: 10) {
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
                }
                
                ActionButton(state: $model.registerButtonState, onTap: {
                    model.registerUser()
                }, backgroundColor: colorScheme == .dark ? .brown : .primary)
            } label: {
                Label(RegistrationConstant.welcomeMessage, systemImage: RegistrationConstant.welcomeIcon)
            }
            .padding()
            .accentColor(GlobalConstant.accentColor)
        }
        .banner(data: $model.bannerData, show: $model.showErrorBanner)
        .navigationTitle(RegistrationConstant.navigationTitle)
    }
}


/** State and functional model for RegistrationView. Handles UI updates, tests
 credentials' form, and dispatches API calls. */
class RegistrationViewModel: ObservableObject {
    
    /* MARK: Model fields */
    
    // SuperView model
    @Published var parentModel: LoginViewModel
    
    // Navigation fields
    @Published var navigateToHome: Bool? = false
    @Published var registeredUser: User = User()
    
    // Data fields
    @Published var nameField: String = ""
    @Published var passwordField: String = ""
    @Published var emailField: String = ""
    
    // Banner and button state fields
    @Published var registerButtonState: ActionButtonState = RegistrationConstant.invalidRegisterButtonState
    @Published var registrationHasError: Bool = false
    @Published var bannerData: BannerModifier.BannerData = BannerModifier.BannerData(title: "", detail: "", type: .Info)
    @Published var showErrorBanner: Bool = false
    
    // Publisher fields
    private var cancellables: Set<AnyCancellable> = []
    private var emailIsValidPublisher: AnyPublisher<Bool, Never> {
        $emailField
            .map { value in
                APIHandler.isValidEmail(value)
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
    
    /* MARK: Model methods */
    
    init(_ parentModel: LoginViewModel) {
        self.parentModel = parentModel
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
    
    /** This method follows these steps:
     1. Creates a user authentication entry with the given credentials
     2. Signs in using those same credentials
     3. Generates a unique username from the provided screen name
     4. Iinstantiates a user model
     5. Uploads the user model to the realtime database
     If the last steps fail, the user's entry in the authentication table is
     deleted to maintain data consistency. */
    func registerUser() {
        registerButtonState = RegistrationConstant.loadingRegisterButtonState
        Auth.auth().createUser(withEmail: self.emailField, password: self.passwordField) { [weak self] _, error in
            guard error == nil else {
                self?.registerButtonState = RegistrationConstant.failedRegisterButtonState
                self?.showBannerWithErrorMessage(error!.localizedDescription)
                return
            }
            Auth.auth().signIn(withEmail: self!.emailField, password: self!.passwordField) { [weak self] _, error in
                guard error == nil else {
                    self?.registerButtonState = RegistrationConstant.failedRegisterButtonState
                    self?.showBannerWithErrorMessage(error!.localizedDescription)
                    return
                }
                APIHandler.availableUsernameFromName(self!.nameField) { generatedUsername, error in
                    guard error == nil else {
                        self?.registerButtonState = RegistrationConstant.failedRegisterButtonState
                        self?.showBannerWithErrorMessage(error!.localizedDescription)
                        APIHandler.attemptToDeleteCurrentUser()
                        return
                    }
                    let newUser = User()
                    newUser
                        .changeName(self!.nameField)
                        .changeUsername(generatedUsername!)
                        .changeEmail(self!.emailField)
                        .push { error in
                        guard error == nil else {
                            self?.registerButtonState = RegistrationConstant.failedRegisterButtonState
                            self?.showBannerWithErrorMessage(error!.localizedDescription)
                            APIHandler.attemptToDeleteCurrentUser()
                            return
                        }
                        self?.registerButtonState = RegistrationConstant.successRegisterButtonState
                        self?.registeredUser = newUser
                        self?.loginUser(newUser)
                    }
                }
            }
        }
    }
    
    func loginUser(_ user: User) {
        self.parentModel.loginUser(user)
    }
    
    /* MARK: Model helper methods */
    
    private func showBannerWithErrorMessage(_ message: String?) {
        guard let message = message else { return }
        bannerData.title = RegistrationConstant.genericErrorBannerTitle
        bannerData.detail = message
        bannerData.type = .Error
        showErrorBanner = true
    }
}


struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(model: RegistrationViewModel(LoginViewModel(RootViewModel())))
    }
}
