//
//  FriendsListViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 03/12/2024.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class FriendsListViewModel: ObservableObject {
    @Published var listFriends: [User?] = []
    @Published var listRequestsSent: [User?] = []
    @Published var listRequests: [User?] = []
    
    init() {
        listenForFollowListChanges(userID: Auth.auth().currentUser!.uid)
    }
    
    func deleteFriend(user: User) {
        if let index = listFriends.firstIndex(where: { $0?.id == user.id }) {
            listFriends.remove(at: index)
        }
    }
    
    func deleteRequestSent(user: User) {
        if let index = listRequestsSent.firstIndex(where: { $0?.id == user.id }) {
            listRequestsSent.remove(at: index)
        }
    }
    
    func deleteRequest(user: User) {
        if let index = listRequests.firstIndex(where: { $0?.id == user.id }) {
            listRequests.remove(at: index)
        }
    }
    
    func listenForFollowListChanges(userID: String) {
        let networkRef = Database.database().reference().child("Networks").child(userID)
        
        networkRef.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            // Parse data snapshot
            if let value = snapshot.value as? [String: Any] {
                // Update followers
                if let friendsArray = value["friends"] as? [String] {
                    self.listFriends.removeAll()
                    for friendsID in friendsArray {
                        User.getUserByID(userID: friendsID) { user in
                            DispatchQueue.main.async {
                                self.listFriends.append(user)
                            }
                        }
                    }
                }
                
                // Update Request Sent
                if let requestSentArray = value["requestsSent"] as? [String] {
                    self.listRequestsSent.removeAll()
                    for requestSentID in requestSentArray {
                        User.getUserByID(userID: requestSentID) { user in
                            DispatchQueue.main.async {
                                self.listRequestsSent.append(user)
                            }
                        }
                    }
                }
                
                // Update requests
                if let requestsArray = value["requests"] as? [String] {
                    self.listRequests.removeAll()
                    for requestID in requestsArray {
                        User.getUserByID(userID: requestID) { user in
                            DispatchQueue.main.async {
                                self.listRequests.append(user)
                            }
                        }
                    }
                }
            }
        }
    }
}
