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
    let id: String
    let name: String
    let age: Int
    let join: TimeInterval
    let region: String
    let nation: Country
    let exp: Int
    let peak: Int
    let achievement: String
    let avatar: String?
    let isPublic: Bool
    
    static func updatePeak(userID: String, newPeak: Int) {
        let db = Database.database().reference()
        db.child("users").child(userID).child("peak").setValue(newPeak) { (error, _) in
            if let error = error {
                print("Failed to update peak: \(error.localizedDescription)")
            } else {
                print("Update peak successfully in Realtime Database")
            }
        }
    }
    
    static func toggleStatus(userID: String, status: Bool) {
        let db = Database.database().reference().child("users").child(userID).child("isPublic")
        db.setValue(status) { (error, _) in
            if let error = error {
                print("Failed to update status: \(error.localizedDescription)")
            } else {
                print("Update status successfully in Realtime Database")
            }
        }
    }
    
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
    
    static func getAllUser(completion: @escaping ([User]) -> Void) {
        let db = Database.database().reference().child("users")
        db.observeSingleEvent(of: .value) { snapshot in
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
    
    static func countFriends(userID: String, completion: @escaping (Int) -> Void) {
        let db = Database.database().reference().child("Networks").child(userID).child("friends")
        
        db.observeSingleEvent(of: .value) { snapshot in
            if let friends = snapshot.value as? [String] {
                completion(friends.count)
            } else {
                completion(0)
            }
        } withCancel: { error in
            print("Error fetching friends: \(error.localizedDescription)")
            completion(0)
        }
    }
    
    static func addFriend(userID: String, friendID: String) {
        let ref = Database.database().reference().child("Networks").child(userID).child("friends")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if var friendsArray = snapshot.value as? [String] {
                // Kiểm tra nếu `newFollowerID` đã tồn tại trong danh sách
                if !friendsArray.contains(friendID) {
                    friendsArray.append(friendID)
                    
                    // Cập nhật danh sách lên Firebase
                    ref.setValue(friendsArray) { error, _ in
                        if let error = error {
                            print("Failed to add friend: \(error.localizedDescription)")
                        } else {
                            print("Friend added successfully.")
                        }
                    }
                } else {
                    print("Friend already exists in the list.")
                }
            } else {
                // Nếu danh sách hiện tại rỗng, khởi tạo danh sách mới
                ref.setValue([friendID]) { error, _ in
                    if let error = error {
                        print("Failed to initialize friend list: \(error.localizedDescription)")
                    } else {
                        print("Friend added successfully to the new list.")
                    }
                }
            }
        }
    }

    static func deleteFriend(userID: String, friendID: String) {
        let ref = Database.database().reference().child("Networks").child(userID).child("friends")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if var friendsArray = snapshot.value as? [String] {
                if let index = friendsArray.firstIndex(of: friendID) {
                    friendsArray.remove(at: index)
                    
                    ref.setValue(friendsArray) { error, _ in
                        if let error = error {
                            print("Failed to delete friend: \(error.localizedDescription)")
                        } else {
                            print("Friend deleted successfully.")
                        }
                    }
                } else {
                    print("Friend ID not found in the list.")
                }
            } else {
                print("Failed to retrieve friends list.")
            }
        }
    }
    
    static func addRequest(userID: String, newRequestID: String) {
        let ref = Database.database().reference().child("Networks").child(userID).child("requests")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if var requestArray = snapshot.value as? [String] {
                // Kiểm tra nếu `newRequestID` đã tồn tại trong danh sách
                if !requestArray.contains(newRequestID) {
                    requestArray.append(newRequestID)
                    
                    // Cập nhật danh sách lên Firebase
                    ref.setValue(requestArray) { error, _ in
                        if let error = error {
                            print("Failed to add request: \(error.localizedDescription)")
                        } else {
                            print("Request added successfully.")
                        }
                    }
                } else {
                    print("User already exists in the requests list.")
                }
            } else {
                // Nếu danh sách hiện tại rỗng, khởi tạo danh sách mới
                ref.setValue([newRequestID]) { error, _ in
                    if let error = error {
                        print("Failed to initialize requests list: \(error.localizedDescription)")
                    } else {
                        print("Request added successfully to the new list.")
                    }
                }
            }
        }
    }

    static func deleteRequest(userID: String, deleteID: String) {
        let ref = Database.database().reference().child("Networks").child(userID).child("requests")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if var requestsArray = snapshot.value as? [String] {
                if let index = requestsArray.firstIndex(of: deleteID) {
                    requestsArray.remove(at: index)
                    
                    ref.setValue(requestsArray) { error, _ in
                        if let error = error {
                            print("Failed to delete request: \(error.localizedDescription)")
                        } else {
                            print("Request deleted successfully.")
                        }
                    }
                } else {
                    print("Request ID not found in the list.")
                }
            } else {
                print("Failed to retrieve request list.")
            }
        }
    }
    
    static func sendRequest(userID: String, newRequestID: String) {
        let ref = Database.database().reference().child("Networks").child(userID).child("requestsSent")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if var requestArray = snapshot.value as? [String] {
                // Kiểm tra nếu `newRequestID` đã tồn tại trong danh sách
                if !requestArray.contains(newRequestID) {
                    requestArray.append(newRequestID)
                    
                    // Cập nhật danh sách lên Firebase
                    ref.setValue(requestArray) { error, _ in
                        if let error = error {
                            print("Failed to add request: \(error.localizedDescription)")
                        } else {
                            print("Request added successfully.")
                        }
                    }
                } else {
                    print("User already exists in the requests list.")
                }
            } else {
                // Nếu danh sách hiện tại rỗng, khởi tạo danh sách mới
                ref.setValue([newRequestID]) { error, _ in
                    if let error = error {
                        print("Failed to initialize requests list: \(error.localizedDescription)")
                    } else {
                        print("Request added successfully to the new list.")
                    }
                }
            }
        }
    }
    
    static func recallRequest(userID: String, deleteID: String) {
        let ref = Database.database().reference().child("Networks").child(userID).child("requestsSent")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if var requestsArray = snapshot.value as? [String] {
                if let index = requestsArray.firstIndex(of: deleteID) {
                    requestsArray.remove(at: index)
                    
                    ref.setValue(requestsArray) { error, _ in
                        if let error = error {
                            print("Failed to delete request: \(error.localizedDescription)")
                        } else {
                            print("Request deleted successfully.")
                        }
                    }
                } else {
                    print("Request ID not found in the list.")
                }
            } else {
                print("Failed to retrieve request list.")
            }
        }
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
                "Challenger" + "\((exp - 6000) % 1000 + 1)"
            case _ where exp >= 3500:
                "Grand Master" + " " + intToRoman((exp - 2500) / 100 + 1)
            case _ where exp >= 3000:
                "Master" + " " + intToRoman((exp - 2500) / 100 + 1)
            case _ where exp >= 2500:
                "Diamond" + " " + intToRoman((exp - 2500) / 100 + 1)
            case _ where exp >= 2000:
                "Emerald" + " " + intToRoman2((exp - 2000) / 100 + 1)
            case _ where exp >= 1500:
                "Platinum" + " " + intToRoman2((exp - 1500) / 100 + 1)
            case _ where exp >= 1000:
                "Gold" + " " + intToRoman2((exp - 1000) / 100 + 1)
            case _ where exp >= 600:
                "Silver" + " " + intToRoman2((exp - 600) / 100 + 1)
            case _ where exp >= 300:
                "Bronze" + " " + intToRoman2((exp - 300) / 100 + 1)
            case _ where exp > 0:
                "Iron" + " " + intToRoman2(exp / 100 + 1)
            default:
                "Unrank N/A"
        }
    }
    
    func getBadgeImg() -> String {
        return switch exp {
            case _ where exp >= 6000:
                "challenger"
            case _ where exp >= 3500:
                "grandmaster"
            case _ where exp >= 3000:
                "master"
            case _ where exp >= 2500:
                "diamond"
            case _ where exp >= 2000:
                "emerald"
            case _ where exp >= 1500:
                "platinum"
            case _ where exp >= 1000:
                "gold"
            case _ where exp >= 600:
                "silver"
            case _ where exp >= 300:
                "bronze"
            case _ where exp > 0:
                "iron"
            default:
                "Unrank N/A"
        }
    }
}
