//
//  RegisterViewViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/06/2024.
//

import Foundation
import FirebaseAuth
import Combine
import FirebaseFirestore
import FirebaseDatabase

class validEmailOrPhone: ObservableObject {
    @Published var emailOrPhone = ""
    
    init(emailOrPhone: String){
        self.emailOrPhone = emailOrPhone
    }
    
    func validateEmail(_ email: String) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegEx = "^[A-Za-z][A-Za-z0-9._%+-]*@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: trimmedEmail)
    }
    
    func validateNumberPhone(_ phone: String) -> Bool {
        let phoneRegEx = "^[0-9]{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: phone)
    }
}

public class RegisterViewViewModel: ObservableObject {
    @Published var emailOrPhone = "" {
        didSet {
            validateInput()
        }
    }
    @Published var password = "" {
        didSet {
            validateInput()
        }
    }
    
    @Published var name = ""{
        didSet {
            validateInput()
        }
    }
    
    @Published var age: Int = 0 {
        didSet {
            validateInput()
        }
    }
    
    @Published var region = "" {
        didSet {
            validateInput()
        }
    }
    
    @Published var nation: Country? {
        didSet {
            validateInput()
        }
    }
    
    @Published var avatar = ""
    @Published var errorMessage = ""
    @Published var isValidInput = false
    @Published var buttonLabel = "Confirm"
    
    init() {}
    
    func createRegisterMethod(_ emailOrPhone: String) -> (any RegisterMethod)? {
        if emailOrPhone.contains("@") {
            let loginMethod = RegisterWithEmail(email: emailOrPhone, password: password, name: name, age: age, region: region, nation: nation!, avatar: avatar)
            loginMethod.updateErrorMessage = { [weak self] errorMessage in
                self?.errorMessage = errorMessage
            }
            return loginMethod
        } else if (emailOrPhone.first?.isNumber == true){
            let loginMethod = RegisterWithPhone(phone: emailOrPhone, password: password, name: name, age: age, region: region)
            return loginMethod
        }
        errorMessage = "Please type the right email or number phone"
        return nil
    }
    
    func register(){
        guard password.count > 6 else {
            errorMessage = "Password is too short"
            return
        }
        guard isExistUserName() else {
            errorMessage = "Username is already existed"
            return
        }
        guard isValidAge() else {
            return
        }
        
        // try to register
        guard let registerMethod = createRegisterMethod(emailOrPhone) else { return }
        registerMethod.register()
    }
    
    private func isExistUserName() -> Bool {
        
        return true
    }
    
    private func isValidAge() -> Bool {
        let currentYear = Calendar.current.component(.year, from: Date())
        let minimumAge = 6
        
        let validBirthYear = currentYear - minimumAge
        
        if age > currentYear {
            errorMessage = "Invalid Year of Birth"
            return false
        } else if age > validBirthYear {
            errorMessage = "You must be at least 6 years old to register"
            return false
        } else {
            return true
        }
    }
    
    private func validateInput() {
        let validator = validEmailOrPhone(emailOrPhone: emailOrPhone)
        if emailOrPhone.contains("@") {
            isValidInput = validator.validateEmail(emailOrPhone) && !password.isEmpty && !name.isEmpty && age != 0
            buttonLabel = "Confirm Email"
        } else if emailOrPhone.first?.isNumber == true {
            isValidInput = validator.validateNumberPhone(emailOrPhone) && !password.isEmpty && !name.isEmpty && age != 0
            buttonLabel = "Confirm Number"
        } else {
            isValidInput = false
        }
    }
}

protocol RegisterMethod: ObservableObject {
    var password: String { get set }
    var name: String { get set }
    var age: Int { get set }
    var region: String { get set }
    var errorMessage: String { get set }
    func register()
}

class RegisterWithEmail: RegisterMethod {
    @Published var email: String
    @Published var password: String
    @Published var name: String
    @Published var age: Int
    @Published var region: String
    @Published var nation: Country
    @Published var avatar: String
    @Published var errorMessage: String = ""
    
    var updateErrorMessage: ((String) -> Void)?
    
    init(email: String, password: String, name: String, age: Int, region: String, nation: Country, avatar: String){
        self.email = email
        self.password = password
        self.name = name
        self.age = age
        self.region = region
        self.nation = nation
        self.avatar = avatar
    }
    
    func register() {
        createAccount { userID in
            if let userID = userID {
                let newUser = self.createNewUser(userID: userID)
                User.insertUser(userID: userID, user: newUser)
            } else {
                print("Failed to create user")
            }
        }
    }
    
    private func createNewUser(userID: String) -> User{
        return User(id: userID, name: name, age: age, join: Date().timeIntervalSince1970, region: region, nation: nation, exp: 0, peak: 0, achievement: "", avatar: avatar, isPublic: true)
    }
    
    private func createAccount(completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userID = result?.user.uid else {
                // Handle error if needed
                completion(nil)
                return
            }
            // Call completion handler with userID
            completion(userID)
        }
    }
}

class RegisterWithPhone: RegisterMethod {
    @Published var phone: String
    @Published var password: String
    @Published var name: String = ""
    @Published var age: Int = 0
    @Published var region: String = ""
    @Published var errorMessage: String = ""
    
    init(phone: String, password: String, name: String, age: Int, region: String){
        self.phone = phone
        self.password = password
        self.name = name
        self.age = age
        self.region = region
    }
    
    func register() {
        errorMessage = ""
        // Implement the registration logic here
    }
}
