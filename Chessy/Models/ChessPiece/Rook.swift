//
//  Rook.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import Foundation

class Rook: ChessPiece {
    var hasMoved: Bool = false // Biến để kiểm tra xem Rook đã di chuyển chưa
    
    override init(color: PlayerColor, position: (Int, Int)) {
        super.init(color: color, position: position)
    }
    
    override func possibleMoves(on board: [[ChessPiece?]]) -> [(Int, Int)] {
        var moves = [(Int, Int)]()

        // Rook có thể di chuyển theo chiều ngang và dọc, kiểm tra các ô trong 4 hướng.
        
        // Di chuyển theo chiều dọc (lên)
        for row in (0..<position.0).reversed() {
            if let piece = board[row][position.1] {
                if piece.color != self.color {
                    moves.append((row, position.1))  // Nếu có quân cờ khác màu, nó có thể ăn.
                }
                break  // Nếu gặp bất kỳ quân cờ nào (cùng màu hoặc khác màu), dừng lại.
            } else {
                moves.append((row, position.1))  // Ô trống, có thể di chuyển đến.
            }
        }

        // Di chuyển theo chiều dọc (xuống)
        for row in (position.0 + 1)..<8 {
            if let piece = board[row][position.1] {
                if piece.color != self.color {
                    moves.append((row, position.1))
                }
                break
            } else {
                moves.append((row, position.1))
            }
        }

        // Di chuyển theo chiều ngang (trái)
        for col in (0..<position.1).reversed() {
            if let piece = board[position.0][col] {
                if piece.color != self.color {
                    moves.append((position.0, col))
                }
                break
            } else {
                moves.append((position.0, col))
            }
        }

        // Di chuyển theo chiều ngang (phải)
        for col in (position.1 + 1)..<8 {
            if let piece = board[position.0][col] {
                if piece.color != self.color {
                    moves.append((position.0, col))
                }
                break
            } else {
                moves.append((position.0, col))
            }
        }

        return moves
    }
    
    // Hàm này cần được gọi khi quân Rook di chuyển
    func move() {
        hasMoved = true
    }
}
