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
    @Published var whiteTurn: Bool?
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
    
    @Published var pieceMoves: [pieceMove]?
        
    init() {
        self.board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        self.roomCode = ""
        self.deadPieces = []
        self.playerID = Auth.auth().currentUser!.uid
                
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
                print("User not found or failed to fetch user data")
                return
            }
            
            // Kiểm tra nếu đã có "whitePiece" trong dữ liệu
            if let whitePlayerID = gameDict["whitePiece"] as? String {
                if whitePlayerID == self.playerID {
                    self.playerColor = .white
                    self.whiteTurn = true
                    self.setupBoard()
                    print("Current player is White")
                } else {
                    self.playerColor = .black
                    self.whiteTurn = true
                    self.setupBoard()
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
                        
                        print("Current number of playerIDs: \(currentCount)")
                        
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
                                self?.deadPieces = []
                                self?.board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
                                self?.whiteTurn = nil
                                
                                gameSnapshot.ref.child("whitePiece").removeValue { error, _ in
                                    if let error = error {
                                        print("Failed to remove whitePiece: \(error.localizedDescription)")
                                    } else {
                                        print("WhitePiece removed")
                                    }
                                }
                            }
                        }
                    } else {
                        print("User not found or failed to fetch user data")
                    }
                    
                    // Observe changes to pieceMoves in Firebase
                    gameSnapshot.ref.child("pieceMoves").observe(.value, with: { [weak self] pieceMovesSnapshot in
                        guard let self = self else { return }
                        
                        if let movesArray = pieceMovesSnapshot.value as? [[String: Any]] {
                            // Convert the array of dictionaries to an array of MovesPieces
                            let decodedMoves: [pieceMove] = movesArray.compactMap { dict in
                                do {
                                    let jsonData = try JSONSerialization.data(withJSONObject: dict)
                                    return try JSONDecoder().decode(pieceMove.self, from: jsonData)
                                } catch {
                                    print("Error decoding pieceMove: \(error)")
                                    return nil
                                }
                            }
                            
                            // Compare and update pieceMoves only if the decoded array is different
                            if pieceMoves?.count != decodedMoves.count {
                                pieceMoves = decodedMoves
                                
                                if let lastMove = self.pieceMoves?.last, lastMove.movedPiece == "Pawn" && lastMove.move.positionAfterMoved.X == 0 && lastMove.pawnPromoted == nil {
                                    pieceMoves = []
                                } else {
                                    if (whiteTurn == true && playerColor != .white) || (whiteTurn == false && playerColor == .white) {
                                        let lastMove = decodedMoves.last
                                        
                                        if let deadPiece = getPiece(at: symmetry(position: (lastMove?.move.positionAfterMoved)!)) {
                                            deadPieces.append(deadPiece)
                                        }
                                        
                                        self.movePiece(from: symmetry(position: (lastMove?.move.possition)!), to: symmetry(position: (lastMove?.move.positionAfterMoved)!), control: false)
                                        
                                        if lastMove?.pawnPromoted != nil {
                                            promoteChoice = lastMove?.pawnPromoted
                                            promote(pawn: getPiece(at: symmetry(position: (lastMove?.move.positionAfterMoved)!))!)
                                        }
                                    }
                                    toggleTurn()
                                }
                            }
                        }
                    })
                    
                    break
                }
            }
        })
    }
    
    func symmetry(position: Position) -> (Int, Int) {
        return (7 - position.X, position.Y)
    }
    
    func getDeadPieces(color: PlayerColor) -> [ChessPiece?] {
        return deadPieces.filter { $0?.color == color }
    }
    
    private func setupBoard() {
        let playerEColor: PlayerColor = self.playerColor == .white ? .black : .white
        board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        
        // Khởi tạo bàn cờ với các quân cờ
        for i in 0..<8 {
            board[6][i] = Pawn(color: self.playerColor!, position: (6, i))
            board[1][i] = Pawn(color: playerEColor, position: (1, i))
        }
        // Đặt các quân cờ khác cho trắng
        board[7][0] = Rook(color: self.playerColor!, position: (7, 0))
        board[7][7] = Rook(color: self.playerColor!, position: (7, 7))
        board[7][1] = Knight(color: self.playerColor!, position: (7, 1))
        board[7][6] = Knight(color: self.playerColor!, position: (7, 6))
        board[7][2] = Bishop(color: self.playerColor!, position: (7, 2))
        board[7][5] = Bishop(color: self.playerColor!, position: (7, 5))
        board[7][3] = Queen(color: self.playerColor!, position: (7, 3))
        board[7][4] = King(color: self.playerColor!, position: (7, 4))
        
        // Đặt các quân cờ khác cho đen
        board[0][0] = Rook(color: playerEColor, position: (0, 0))
        board[0][7] = Rook(color: playerEColor, position: (0, 7))
        board[0][1] = Knight(color: playerEColor, position: (0, 1))
        board[0][6] = Knight(color: playerEColor, position: (0, 6))
        board[0][2] = Bishop(color: playerEColor, position: (0, 2))
        board[0][5] = Bishop(color: playerEColor, position: (0, 5))
        board[0][3] = Queen(color: playerEColor, position: (0, 3))
        board[0][4] = King(color: playerEColor, position: (0, 4))
    }

    func movePiece(from start: (Int, Int), to end: (Int, Int), control: Bool) {
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
        
        if let pawn = piece as? Pawn, end.0 == 0 && control {
            pawnPromoted = pawn
            promote = true
        }
        
        if control {
            // Save piece moved
            if pieceMoves != nil {
                pieceMoves?.append(getPieceMove(piece: piece, from: start, to: end))
            } else {
                pieceMoves = [getPieceMove(piece: piece, from: start, to: end)]
            }
            
            MatchModel.saveMovePiece(pieceMoves: pieceMoves!, roomID: self.roomCode)
            pieceMoves = []
        }
    }
    
    func getPieceMove(piece: ChessPiece, from start: (Int, Int), to end: (Int, Int)) -> pieceMove {
        let startPosition = Position(X: start.0, Y: start.1)
        let endPosition = Position(X: end.0, Y: end.1)
        let move = Move(possition: startPosition, positionAfterMoved: endPosition)
        
        // Get piece color and type
        let pieceColor = piece.color == .white ? "white" : "black"
        let pieceType = String(describing: type(of: piece))
        
        // Create the MovesPieces object
        return pieceMove(pieceColor: pieceColor, movedPiece: pieceType, move: move, pawnPromoted: promoteChoice)
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
        MatchModel.promote(roomID: roomCode, promotedPiece: promoteChoice!)
        
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
        whiteTurn!.toggle()
    }

    func getPiece(at position: (Int, Int)) -> ChessPiece? {
        return board[position.0][position.1]
    }
    
    func resetGame() {
        setupBoard()
    }
}
