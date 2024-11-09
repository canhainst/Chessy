//
//  ChessGameViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class ChessGameViewModel: ObservableObject {
    @Published private(set) var board: [[ChessPiece?]]
    @Published var whiteTurn: Bool
    @Published var roomCode: String
    @Published var deadPieces: [ChessPiece?]
    
    @Published var promote = false
    @Published var promoteChoice: String?
    @Published var pawnPromoted: ChessPiece?
    
    @Published var playerEID: String?
    @Published var playerE: User?
    @Published var avatarE: String?
    
    @Published var playerID: String
    @Published var player: User?
    @Published var avatar: String?
    
    @Published var playerColor: PlayerColor?
    @Published var isHost: Bool?
        
    init() {
        self.board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        self.roomCode = ""
        self.deadPieces = []
        self.playerID = Auth.auth().currentUser!.uid
        self.whiteTurn = true
        
        setupBoard()
        
        User.getUserByID(userID: playerID) { [weak self] user in
            if let user = user {
                self?.player = user
            } else {
                print("User not found or failed to fetch user data")
            }
        }
    }
    
    func setPlayerColor(roomCode: String) {
        let db = Database.database().reference()
            
        let query = db.child("games").queryOrdered(byChild: "roomID").queryEqual(toValue: roomCode)
        
        query.observeSingleEvent(of: .value) { snapshot in
            guard let gameData = snapshot.children.allObjects.first as? DataSnapshot,
                  let gameDict = gameData.value as? [String: Any],
                  let _ = gameDict["playerID"] as? [String] else {
                print("Không tìm thấy game hoặc không có playerID nào.")
                return
            }
            
            // Kiểm tra nếu đã có "whitePiece" trong dữ liệu
            if let whitePlayerID = gameDict["whitePiece"] as? String {
                if whitePlayerID == self.playerID {
                    self.playerColor = .white
                    self.whiteTurn = true
                    print("Current player is White")
                } else {
                    self.playerColor = .black
                    self.whiteTurn = false
                    print("Current player is Black")
                }
            }
        }
    }
    
    func listenForGameChanges(roomCode: String) {
        let gamesRef = Database.database().reference().child("games")
        
        gamesRef.observe(.value, with: { [weak self] snapshot in
            guard self != nil else { return }
            
            for child in snapshot.children {
                if let gameSnapshot = child as? DataSnapshot,
                   let gameData = gameSnapshot.value as? [String: Any],
                   let gameRoomID = gameData["roomID"] as? String,
                   gameRoomID == roomCode {
                    
                    print("Found game with roomCode \(roomCode)")
                    
                    if let host = gameData["host"] as? String {
                        self?.isHost = (self?.playerID == host)
                    }
                    
                    if let playerIDs = gameData["playerID"] as? [String] {
                        let currentCount = playerIDs.count
                        
                        print("Số lượng playerID hiện tại: \(currentCount)")
                        
                        for (index, playerID) in playerIDs.enumerated() {
                            print("PlayerID \(index): \(playerID)")
                            if currentCount == 2 {
                                if playerID != self?.playerID {
                                    self?.playerEID = playerID
                                    User.getUserByID(userID: (self?.playerEID)!) { [weak self] user in
                                        if let user = user {
                                            self?.playerE = user
                                        } else {
                                            print("User not found or failed to fetch user data")
                                        }
                                    }
                                }
                            }
                            if currentCount == 1 {
                                self?.playerEID = nil
                                self?.playerE = nil
                                
                                gameSnapshot.ref.child("whitePiece").removeValue { error, _ in
                                    if let error = error {
                                        print("Failed to remove whitePiece: \(error.localizedDescription)")
                                    } else {
                                        print("whitePiece removed as only one player left in the game")
                                    }
                                }
                            }
                        }
                    } else {
                        print("Không có playerID nào trong game này.")
                    }                    
                    break
                }
            }
        })
    }
    
    func getDeadPieces(color: PlayerColor) -> [ChessPiece?] {
        return deadPieces.filter { $0?.color == color }
    }
    
    private func setupBoard() {
        // Khởi tạo bàn cờ với các quân cờ
        for i in 0..<8 {
            board[6][i] = Pawn(color: .white, position: (6, i)) // Quân cờ trắng
            board[1][i] = Pawn(color: .black, position: (1, i)) // Quân cờ đen
        }
        // Đặt các quân cờ khác cho trắng
        board[7][0] = Rook(color: .white, position: (7, 0))
        board[7][7] = Rook(color: .white, position: (7, 7))
        board[7][1] = Knight(color: .white, position: (7, 1))
        board[7][6] = Knight(color: .white, position: (7, 6))
        board[7][2] = Bishop(color: .white, position: (7, 2))
        board[7][5] = Bishop(color: .white, position: (7, 5))
        board[7][3] = Queen(color: .white, position: (7, 3))
        board[7][4] = King(color: .white, position: (7, 4))
        
        // Đặt các quân cờ khác cho đen
        board[0][0] = Rook(color: .black, position: (0, 0))
        board[0][7] = Rook(color: .black, position: (0, 7))
        board[0][1] = Knight(color: .black, position: (0, 1))
        board[0][6] = Knight(color: .black, position: (0, 6))
        board[0][2] = Bishop(color: .black, position: (0, 2))
        board[0][5] = Bishop(color: .black, position: (0, 5))
        board[0][3] = Queen(color: .black, position: (0, 3))
        board[0][4] = King(color: .black, position: (0, 4))
    }

    func movePiece(from start: (Int, Int), to end: (Int, Int)) {
        guard let piece = board[start.0][start.1] else { return }
        
        if let _ = board[end.0][end.1] {
            board[end.0][end.1] = nil
        }

        // Kiểm tra nếu quân cờ là vua và thực hiện nhập thành
        if piece is King && abs(start.1 - end.1) == 2 {
            piecesCastling(from: start, to: end)
        }

        // Di chuyển quân cờ bình thường
        board[end.0][end.1] = piece
        board[start.0][start.1] = nil
        piece.position = end
        
        if let pawn = piece as? Pawn {
            if (pawn.color == .white && end.0 == 0) || (pawn.color == .black && end.0 == 7) {
                pawnPromoted = pawn
                promote = true
            }
        }
        
        toggleTurn()
    }
    
    func promote(pawn: ChessPiece) {
        // Lấy vị trí của quân cờ
        let end = pawn.position

        let chessPiecePromoted: ChessPiece
        
        switch promoteChoice {
        case "queen":
            chessPiecePromoted = Queen(color: pawn.color, position: end) // Sử dụng end
        case "knight":
            chessPiecePromoted = Knight(color: pawn.color, position: end)
        case "rook":
            chessPiecePromoted = Rook(color: pawn.color, position: end)
        case "bishop":
            chessPiecePromoted = Bishop(color: pawn.color, position: end)
        default:
            chessPiecePromoted = Queen(color: pawn.color, position: end) // Mặc định là quân hậu
        }
        
        // Đặt quân cờ đã thăng cấp vào bàn cờ
        board[end.0][end.1] = chessPiecePromoted
        promoteChoice = nil // Reset lựa chọn sau khi thăng cấp
        pawnPromoted = nil
    }
    
    func piecesCastling(from start: (Int, Int), to end: (Int, Int)) {
        let row = start.0

        if end.1 > start.1 {
            // Nhập thành bên phải
            if let rook = board[row][7], rook is Rook {
                board[row][5] = rook
                board[row][7] = nil
                rook.position = (row, 5)
            }
        } else {
            // Nhập thành bên trái
            if let rook = board[row][0], rook is Rook {
                board[row][3] = rook
                board[row][0] = nil
                rook.position = (row, 3)
            }
        }
    }

    
    func toggleTurn() {
        whiteTurn.toggle()
    }

    func getPiece(at position: (Int, Int)) -> ChessPiece? {
        return board[position.0][position.1]
    }
    
    func resetGame() {
        setupBoard()
    }
}
