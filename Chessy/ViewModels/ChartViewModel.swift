//
//  ChartViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 16/06/2024.
//

import Foundation

class ChartViewModel: ObservableObject {
    @Published var users: [User]? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchUsersListByRegion(region: String) {
        self.isLoading = true
        self.errorMessage = nil
        
        User.getAllUserByRegion(region: region) { [weak self] users in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.users = users
            }
        }
    }
    
    func sortUserListByExp(_ users: [User]) -> [User] {
        return users.sorted { $0.exp > $1.exp }
    }
}
