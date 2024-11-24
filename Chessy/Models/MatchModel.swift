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

struct pieceMove: Codable {
    let pieceColor: String
    let movedPiece: String
    let move: Move
    var pawnPromoted: String?
}

struct MatchModel: Codable {
    let gameID: UUID
    let roomID: String
    let playerID: [String?]
    var pieceMoves: [pieceMove?]
    let winnerID: String?
    let host: String
    let whitePiece: String?
    let rematch: [Bool]?
    
    static func deleteGame(roomID: String){
        let db = Database.database().reference()
        let query = db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: roomID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            guard let gameSnapshot = snapshot.children.allObjects.first as? DataSnapshot else {
                print("Error: Could not find game with roomID \(roomID).")
                return
            }
            
            gameSnapshot.ref.updateChildValues([
                "pieceMoves": NSNull(),
                "winnerID": NSNull(),
                "whitePiece": NSNull()
            ]) { error, _ in
                if let error = error {
                    print("Error updating game fields: \(error.localizedDescription)")
                } else {
                    print("Successfully deleted fields from game with roomID \(roomID).")
                }
            }
        }
    }
    
    static func saveGame(gameID: UUID, playerIDs: [String], winnerID: String, historyPoint: [(String, Int)]){
        let db = Database.database().reference().child("GamePlayed")
        
        let gameData: [String: Any] = [
            "playerID": playerIDs,
            "winnerID": winnerID,
            "historyPoint": historyPoint.map { ["playerID": $0.0, "points": $0.1] },
            "timestamp": Date().timeIntervalSince1970
        ]
        
        db.child(gameID.uuidString).setValue(gameData) { error, _ in
            if let error = error {
                print("Error saving game: \(error.localizedDescription)")
            } else {
                print("Game saved successfully.")
            }
        }
    }
    
    static func rematch(roomID: String) {
        let db = Database.database().reference()
        let query = db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: roomID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            guard let gameSnapshot = snapshot.children.allObjects.first as? DataSnapshot else {
                print("Error: Could not find game with roomID \(roomID).")
                return
            }
            
            gameSnapshot.ref.child("rematch").observeSingleEvent(of: .value) { rematchSnapshot in
                var rematchArray: [Bool] = []
                
                if let existingRematch = rematchSnapshot.value as? [Bool] {
                    rematchArray = existingRematch
                }
                
                // Thêm `true` vào mảng rematch
                rematchArray.append(true)
                
                // Cập nhật lại giá trị vào Firebase
                gameSnapshot.ref.updateChildValues(["rematch": rematchArray]) { error, _ in
                    if let error = error {
                        print("Error updating rematch: \(error.localizedDescription)")
                    } else {
                        print("Successfully added true to rematch for roomID \(roomID).")
                    }
                }
            }
        }
    }
    
    static func promote(roomID: String, promotedPiece: String) {
        let db = Database.database().reference()
        
        let query = db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: roomID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            guard let gameSnapshot = snapshot.children.allObjects.first as? DataSnapshot,
                  let matchData = try? gameSnapshot.data(as: MatchModel.self) else {
                print("Error: Could not retrieve or decode MatchModel.")
                return
            }
            
            var pieceMoves = matchData.pieceMoves
            pieceMoves[matchData.pieceMoves.count - 1]?.pawnPromoted = promotedPiece
            
            gameSnapshot.ref.child("pieceMoves").setValue(pieceMoves.map { $0.asDictionary() }) { error, _ in
                if let error = error {
                    print("Failed to update movesPieces: \(error.localizedDescription)")
                } else {
                    print("movesPieces updated successfully in Firebase.")
                }
            }
        }
    }
    
    static func saveMovePiece(pieceMoves: [pieceMove], roomID: String) {
        let db = Database.database().reference()
        
        // Tìm game có roomID được cung cấp
        let query = db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: roomID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            // Kiểm tra xem có dữ liệu không
            guard let gameSnapshot = snapshot.children.allObjects.first as? DataSnapshot,
                  let gameData = gameSnapshot.value as? [String: Any],
                  let playerIDs = gameData["playerID"] as? [String],
                  !playerIDs.isEmpty else {
                print("Room ID not found.")
                return
            }
            
            // Convert each MovesPieces object to a dictionary using asDictionary()
            let movesArray = pieceMoves.map { $0.asDictionary() }
            
            // Update the movesPieces field in Firebase
            gameSnapshot.ref.child("pieceMoves").setValue(movesArray) { error, _ in
                if let error = error {
                    print("Failed to update movesPieces: \(error.localizedDescription)")
                } else {
                    print("movesPieces updated successfully in Firebase.")
                }
            }
        }
    }
    
    static func setWinner(roomID: String, winnerID: String) {
        let db = Database.database().reference()
        
        // Tìm game có roomID được cung cấp
        let query = db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: roomID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            // Kiểm tra xem có dữ liệu không
            guard let gameSnapshot = snapshot.children.allObjects.first as? DataSnapshot else {
                print("Room ID not found.")
                return
            }
            
            gameSnapshot.ref.child("winnerID").setValue(winnerID) { error, _ in
                if let error = error {
                    print("Failed to set winnerID: \(error.localizedDescription)")
                } else {
                    print("Winner ID: \(winnerID)")
                }
            }
        }
    }
    
    static func setWhitePiece(roomID: String){
        let db = Database.database().reference()
        
        // Tìm game có roomID được cung cấp
        let query = db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: roomID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            // Kiểm tra xem có dữ liệu không
            guard let gameSnapshot = snapshot.children.allObjects.first as? DataSnapshot,
                  let gameData = gameSnapshot.value as? [String: Any],
                  let playerIDs = gameData["playerID"] as? [String],
                  !playerIDs.isEmpty else {
                print("Room ID not found.")
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
    
    static func insertNewGame(matchModel: MatchModel, completion: @escaping (Bool) -> Void) {
            let db = Database.database().reference()
            
            // Kiểm tra xem roomID đã tồn tại chưa
            db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: matchModel.roomID).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    // Mã phòng đã tồn tại
                    print("Room code already exists. Insertion failed.")
                    completion(false)
                } else {
                    // Mã phòng chưa tồn tại, cho phép thêm vào
                    db.child("games").child(matchModel.gameID.uuidString).setValue(matchModel.asDictionary()) { (error, _) in
                        if let error = error {
                            print("Failed to save game: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Game saved successfully in Realtime Database")
                            completion(true)
                        }
                    }
                }
            }
        }
    
    static func joinGame(playerID: String, roomID: String, completion: @escaping (Int) -> Void) {
        let db = Database.database().reference()

        // Tìm game theo roomID
        let query = db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: roomID)

        query.observeSingleEvent(of: .value) { snapshot in
            guard let gamesData = snapshot.value as? [String: Any] else {
                print("Không tìm thấy game với roomID này")
                completion(1)  // Return error code 1 if room is not found
                return
            }

            if let gameKey = gamesData.keys.first,
               var game = gamesData[gameKey] as? [String: Any] {

                // Kiểm tra số lượng người chơi hiện tại
                if var players = game["playerID"] as? [String] {
                    // Kiểm tra nếu đã có 2 người chơi
                    if players.count >= 2 {
                        print("Phòng đã có đủ 2 người chơi")
                        completion(2)  // Return error code 2 if the room already has 2 players
                        return
                    }

                    // Thêm playerID mới vào danh sách nếu nó chưa có
                    if !players.contains(playerID) {
                        players.append(playerID)
                        game["playerID"] = players

                        // Cập nhật lại trong Firebase
                        db.child("games").child(gameKey).updateChildValues(["playerID": players]) { error, _ in
                            if let error = error {
                                print("Lỗi khi cập nhật playerID: \(error.localizedDescription)")
                                completion(3)  // Return 0 for any error during the update
                            } else {
                                print("Cập nhật playerID thành công")
                                completion(0)  // Return success code 3 when the player is added successfully
                            }
                        }
                    } else {
                        print("playerID đã tồn tại trong game")
                        completion(3)  // Return 0 if the player already exists in the game
                    }
                } else {
                    print("Không tìm thấy playerID trong game")
                    completion(3)  // Return 0 if playerID is missing in the game data
                }
            } else {
                print("Không tìm thấy game với roomID này")
                completion(1)  // Return error code 1 if the game with roomID is not found
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
                                    
                                    // Remove the pieceMoves array
                                    gameSnapshot.ref.child("pieceMoves").removeValue { (error, _) in
                                        if let error = error {
                                            print("Failed to delete pieceMoves: \(error.localizedDescription)")
                                        } else {
                                            print("pieceMoves array deleted successfully")
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
