//
//  HomeViewViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/12/2024.
//

import Foundation

class HomeViewViewModel: ObservableObject {
    @Published var dataUser: [User?]
    
    init () {
        self.dataUser = []
        
        User.getAllUser { userList in
            self.dataUser = userList
        }
    }
}
