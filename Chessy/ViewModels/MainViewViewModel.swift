//
//  MainViewViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class MainViewViewModel: ObservableObject {
    @Published var currentUserID: String = ""
    @Published var challengerID: String = ""
    @Published var code: String = ""
    @Published var isPlayGame: Bool = false {
        didSet {
            if !isPlayGame {
                listenForChallenge()
            }
        }
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var challengeHandle: DatabaseHandle?
    private let databaseRef = Database.database().reference()
    
    init() {
        // Lắng nghe trạng thái đăng nhập
        self.authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let user = user {
                    // Người dùng đã đăng nhập
                    self.currentUserID = user.uid
                    self.listenForChallenge()
                } else {
                    // Người dùng chưa đăng nhập hoặc đã đăng xuất
                    self.stopListeningForChallenge()
                    self.currentUserID = ""
                }
            }
        }
    }
    
    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    func listenForChallenge() {
        self.stopListeningForChallenge()
        
        guard !currentUserID.isEmpty else { return }
        let challengeRef = databaseRef.child("Challenges").child(currentUserID)
        challengeHandle = challengeRef.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            if let value = snapshot.value as? [String: Any] {
                if let challengerID = value["challengerID"] as? String {
                    self.challengerID = challengerID
                }
                if let code = value["code"] as? String {
                    self.code = code
                    MatchModel.joinGame(playerID: self.currentUserID, roomID: code) { code in
                        if code == 0 {
                            self.isPlayGame = true
                            
                            return
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.challengerID = ""
                    self.code = ""
                }
            }
        }
    }
    
    func stopListeningForChallenge() {
        guard !currentUserID.isEmpty, let challengeHandle = challengeHandle else {
            return
        }
        databaseRef.child("Challenges").child(currentUserID).removeObserver(withHandle: challengeHandle)
        self.challengeHandle = nil
    }
    
    deinit {
        if let authStateHandler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(authStateHandler)
        }
        stopListeningForChallenge()
    }
}
