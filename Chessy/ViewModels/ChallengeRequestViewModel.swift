//
//  ChallengeRequestViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 07/12/2024.
//

import Foundation

class ChallengeRequestViewModel: ObservableObject {
    @Published var isChallenged: Bool = false
    @Published var userID: String
    @Published var userChallenge: User?
    
    init(userID: String, userChallenge: User? = nil) {
        self.userID = userID
        User.getUserByID(userID: userID) { user in
            self.userChallenge = user
            self.isChallenged = true
        }
    }
    
    
}
