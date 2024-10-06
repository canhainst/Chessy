//
//  LoginViewViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 04/06/2024.
//

import Foundation
import FirebaseAuth

protocol LoginProtocol: ObservableObject {
    var password: String { get set }
    var errorMessage: String { get set }
    func login()
    func validate(_ emailOrPhone: String) -> Bool
}

public class LoginViewViewModel: ObservableObject {
    @Published var emailOrPhone = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    init(){}
    
    func createLoginMethod(_ emailOrPhone: String) -> (any LoginProtocol)? {
        if emailOrPhone.contains("@") {
            let loginMethod = LoginWithEmail(email: emailOrPhone, password: password)
            loginMethod.updateErrorMessage = { [weak self] errorMessage in
                self?.errorMessage = errorMessage
            }
            return loginMethod
        } else if (emailOrPhone.first?.isNumber == true){
            return LoginWithPhone(phone: emailOrPhone, password: password)
        }
        errorMessage = "Please type the right email or number phone"
        return nil
    }
    
    func login() {
        // Default implementation if needed
        guard let loginMethod = createLoginMethod(emailOrPhone) else { return }
        loginMethod.login()
        errorMessage = loginMethod.errorMessage
    }
    
    func validate(_ emailOrNumber: String) -> Bool {
        // Default validation if needed
        return true
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            self.errorMessage = "Error signing out: \(signOutError.localizedDescription)"
        }
    }
}

class LoginWithEmail: LoginProtocol {
    @Published var email: String
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    
    var updateErrorMessage: ((String) -> Void)?
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    func login() {
        errorMessage = ""
        guard validate(email) else {
            errorMessage = "Please input the right email"
            return
        }
        loginWithEmail(email, password: password)
    }
    
    func validate(_ email: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegEx = "^[A-Za-z][A-Za-z0-9._%+-]*@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: trimmedEmail)
    }
    
    private func loginWithEmail(_ email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if error != nil {
                self.updateErrorMessage?("Failed to login with email")
            } else if authResult != nil {
                self.updateErrorMessage?("Success")
            } else {
                // Unexpected error, handle accordingly
                _ = NSError(domain: "SignInError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected error occurred during sign in."])
            }
        }
    }
}

class LoginWithPhone: LoginProtocol {
    @Published var phone: String
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    
    init(phone: String, password: String) {
        self.phone = phone
        self.password = password
    }
    
    func login() {
        errorMessage = ""
        guard validate(phone) else {
            errorMessage = "Please input the right phone number"
            return
        }
        loginWithPhone(phone, password: password)
    }
    
    func validate(_ phone: String) -> Bool {
        let phoneRegEx = "^[0-9]{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: phone)
    }
    
    private func loginWithPhone(_ phone: String, password: String) {
        // Implement login with phone logic here
    }
}
