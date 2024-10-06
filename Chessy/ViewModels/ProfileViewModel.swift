//
//  ProfileViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 15/06/2024.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchUser(userID: String) {
        self.isLoading = true
        User.getUserByID(userID: userID) { [weak self] user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let user = user {
                    self.user = user
                } else {
                    self.errorMessage = "Failed to load user."
                }
            }
        }
    }
    
    func saveUser(userID: String, user: User) {
        self.isLoading = true
        User.insertUser(userID: userID, user: user)
        DispatchQueue.main.async {
            self.isLoading = false
            self.user = user
            self.errorMessage = nil
        }
    }
    
}
