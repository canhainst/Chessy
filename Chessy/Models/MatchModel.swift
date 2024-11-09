//
//  MatchModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 12/10/2024.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseFirestore

struct Position: Codable {
    let X: Int
    let Y: Int
}

struct Move: Codable {
    let possition: Position
    let positionAfterMoved: Position
}

struct MovesPieces: Codable {
    let movedPiece: String
    let move: Move
}

struct MatchModel: Codable {
    let gameID: UUID
    let roomID: String
    let playerID: [String?]
    let movesPieces: [MovesPieces?]
    let playerWinID: String?
    let host: String
    let whitePiece: String?
    
    static func setWhitePiece(roomID: String) {
        let db = Database.database().reference()
        
        // Tìm game có roomID được cung cấp
        let query = db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: roomID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            // Kiểm tra xem có dữ liệu không
            guard let gameSnapshot = snapshot.children.allObjects.first as? DataSnapshot,
                  let gameData = gameSnapshot.value as? [String: Any],
                  let playerIDs = gameData["playerID"] as? [String],
                  !playerIDs.isEmpty else {
                print("Không tìm thấy game hoặc danh sách playerID trống.")
                return
            }
            
            // Chọn ngẫu nhiên một playerID từ danh sách playerIDs
            let randomIndex = Int.random(in: 0..<playerIDs.count)
            let randomPlayerID = playerIDs[randomIndex]
            
            // Cập nhật whitePiece với ID người chơi ngẫu nhiên
            gameSnapshot.ref.child("whitePiece").setValue(randomPlayerID) { error, _ in
                if let error = error {
                    print("Failed to set whitePiece: \(error.localizedDescription)")
                } else {
                    print("whitePiece set to playerID: \(randomPlayerID)")
                }
            }
        }
    }
    
    static func insertNewGame(matchModel: MatchModel) {
        let db = Database.database().reference()
        db.child("games").child(matchModel.gameID.uuidString).setValue(matchModel.asDictionary()) { (error, _) in
            if let error = error {
                print("Failed to save game: \(error.localizedDescription)")
            } else {
                print("Game saved successfully in Realtime Database")
            }
        }
    }
    
    static func joinGame(playerID: String, roomID: String) {
        let db = Database.database().reference()
        
        // Tìm game theo roomID
        let query = db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: roomID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            guard let gamesData = snapshot.value as? [String: Any] else {
                print("Không tìm thấy game với roomID này")
                return
            }
            
            if let gameKey = gamesData.keys.first,
               var game = gamesData[gameKey] as? [String: Any] {
                
                // Kiểm tra nếu trường playerID đã tồn tại
                if var players = game["playerID"] as? [String] {
                    // Thêm playerID mới vào danh sách nếu nó chưa có
                    if !players.contains(playerID) {
                        players.append(playerID)
                        game["playerID"] = players
                        
                        // Cập nhật lại trong Firebase
                        db.child("games").child(gameKey).updateChildValues(["playerID": players]) { error, _ in
                            if let error = error {
                                print("Lỗi khi cập nhật playerID: \(error.localizedDescription)")
                            } else {
                                print("Cập nhật playerID thành công")
                            }
                        }
                    } else {
                        print("playerID đã tồn tại trong game")
                    }
                }
            } else {
                print("Không tìm thấy game với roomID này")
            }
        }
    }

    
    static func exitGame(playerID: String, roomID: String) {
        let db = Database.database().reference()
        
        // Truy vấn game dựa trên roomCode
        let query = db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: roomID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            // Duyệt qua các trận đấu tìm được
            for case let gameSnapshot as DataSnapshot in snapshot.children {
                if let matchData = gameSnapshot.value as? [String: Any],
                   var players = matchData["playerID"] as? [String] {
                    
                    // Tìm và xóa playerID khỏi mảng
                    if let index = players.firstIndex(of: playerID) {
                        players.remove(at: index)
                        
                        if players.isEmpty {
                            // Nếu mảng playerID rỗng, xóa toàn bộ game
                            gameSnapshot.ref.removeValue { (error, _) in
                                if let error = error {
                                    print("Failed to delete game: \(error.localizedDescription)")
                                } else {
                                    print("Game deleted successfully from Realtime Database")
                                }
                            }
                        } else {
                            // Nếu mảng playerID không rỗng, cập nhật lại mảng playerID trong Firebase
                            gameSnapshot.ref.child("playerID").setValue(players) { (error, _) in
                                if let error = error {
                                    print("Failed to remove player: \(error.localizedDescription)")
                                } else {
                                    print("Player removed successfully from game")
                                    
                                    let newHost = players.first!
                                    gameSnapshot.ref.child("host").setValue(newHost) { (error, _) in
                                        if let error = error {
                                            print("Failed to update host: \(error.localizedDescription)")
                                        } else {
                                            print("Host updated successfully to \(newHost)")
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        print("Player not found in the game")
                    }
                } else {
                    print("Failed to retrieve match data")
                }
            }
        }
    }
}
