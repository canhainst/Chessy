//
//  ChallengeModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 07/12/2024.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseFirestore

struct Challenge: Codable {
    let challengerID: String
    let code: String?
    let isAccepted: Bool?
    
    static func listenForAcceptance(userID: String, completion: @escaping (Bool) -> Void) {
        let db = Database.database().reference().child("Challenges").child(userID).child("isAccepted")
        
        db.observe(.value) { snapshot in
            if let value = snapshot.value as? Bool {
                completion(value)
                db.removeAllObservers()
            } else {
                print("isAccepted not found.")
            }
        }
    }
    
    static func setRoomCode(userID: String, roomID: String) {
        let db = Database.database().reference().child("Challenges").child(userID).child("code")
        db.setValue(roomID) { error, _ in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Update code successfully: \(roomID)")
            }
        }
    }
    
    static func replyChallenge(userID: String, isAccept: Bool) {
        let db = Database.database().reference().child("Challenges").child(userID).child("isAccepted")
        db.setValue(isAccept) { error, _ in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Update isAccepted: \(isAccept)")
            }
        }
    }
    
    static func challengeTo(userID: String, challenge: Challenge, completion: @escaping (Bool) -> Void) {
        let db = Database.database().reference().child("Challenges").child(userID)
        db.setValue(challenge.asDictionary()) { (error, _) in
            if let error = error {
                print("Failed to send challenge: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Sent challenge successfully in Realtime Database")
                completion(true)
            }
        }
    }
    
    static func cancelChallenge(userID: String) {
        let db = Database.database().reference().child("Challenges").child(userID)
        db.removeValue { error, _ in
            if let error = error {
                print("Error canceling challenge: \(error.localizedDescription)")
            } else {
                print("Challenge successfully canceled for userID: \(userID)")
            }
        }
    }
}
