//
//  UserModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseFirestore

struct User: Codable {
    let name: String
    let age: Int
    let join: TimeInterval
    let region: String
    let exp: Int
    let followers: [String]?
    let following: [String]?
    let totalMatches: Int
    let winrate: Float
    let winStreak: Int
    let peak: Int
    let achievement: String
    
    static func insertUser(userID: String, user: User) {
        let db = Database.database().reference()
        db.child("users").child(userID).setValue(user.asDictionary()) { (error, _) in
            if let error = error {
                print("Failed to save user: \(error.localizedDescription)")
            } else {
                print("User saved successfully in Realtime Database")
            }
        }
    }
    
    static func getUserByID(userID: String, completion: @escaping (User?) -> Void) {
        let db = Database.database().reference()
        db.child("users").child(userID).observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? NSDictionary else {
                completion(nil)
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                let user = try JSONDecoder().decode(User.self, from: jsonData)
                completion(user)
            } catch let error {
                print("Failed to decode user: \(error.localizedDescription)")
                completion(nil)
            }
        })
    }
    
    static func getAllUserByRegion(region: String, completion: @escaping ([User]) -> Void) {
        let db = Database.database().reference().child("users")
        db.queryOrdered(byChild: "region").queryEqual(toValue: region)
            .observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [String: Any] else {
                    completion([])
                    return
                }
                
                let userIDs = value.keys.map { $0 }
                
                var users: [User] = []
                let dispatchGroup = DispatchGroup()
                
                for userID in userIDs {
                    dispatchGroup.enter()
                    getUserByID(userID: userID) { user in
                        if let user = user {
                            users.append(user)
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(users)
                }
            }
    }
    
    func joinDateFormatted() -> String {
        let date = Date(timeIntervalSince1970: join)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    func countFollower() -> Int {
        return followers?.count ?? 0
    }
    
    func countFollowing() -> Int {
        return following?.count ?? 0
    }
    
    func Winrate() -> String {
        return String(format: "%.2f%", winrate * 100)
    }
    
    func intToRoman(_ num: Int) -> String {
        let romanValues = [
            (1000, "M"), (900, "CM"), (500, "D"), (400, "CD"),
            (100, "C"), (90, "XC"), (50, "L"), (40, "XL"),
            (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")
        ]
        
        var result = ""
        var number = num
        
        for (value, numeral) in romanValues {
            while number >= value {
                result += numeral
                number -= value
            }
        }
        
        return result
    }
    
    func intToRoman2(_ num: Int) -> String {
        switch num {
        case 5: return "I"
        case 4: return "II"
        case 3: return "III"
        case 2: return "IV"
        case 1: return "V"
        default: return ""
        }
    }
    
    func setRank() -> String {
        return switch exp {
                        case _ where exp >= 6000:
                            "Conqueror"
                        case _ where exp >= 3500:
                            "ACE Domination" + " " + intToRoman((exp - 2500) / 100 + 1)
                        case _ where exp >= 3000:
                            "ACE Master" + " " + intToRoman((exp - 2500) / 100 + 1)
                        case _ where exp >= 2500:
                            "ACE" + " " + intToRoman((exp - 2500) / 100 + 1)
                        case _ where exp >= 2000:
                            "Crown" + " " + intToRoman2((exp - 2000) / 100 + 1)
                        case _ where exp >= 1500:
                            "Diamond" + " " + intToRoman2((exp - 1500) / 100 + 1)
                        case _ where exp >= 1000:
                            "Platinum" + " " + intToRoman2((exp - 1000) / 100 + 1)
                        case _ where exp >= 600:
                            "Gold" + " " + intToRoman2((exp - 600) / 100 + 1)
                        case _ where exp >= 300:
                            "Silver" + " " + intToRoman2((exp - 300) / 100 + 1)
                        case _ where exp > 0:
                            "Bronze" + " " + intToRoman2(exp / 100 + 1)
                        default:
                            "Unrank"
                    }
    }
}
