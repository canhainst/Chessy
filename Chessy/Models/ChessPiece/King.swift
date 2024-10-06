//
//  King.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import Foundation

class King: ChessPiece {
    var hasMoved: Bool = false // Biến để kiểm tra xem Vua đã di chuyển chưa
    
    override init(color: PlayerColor, position: (Int, Int)) {
        super.init(color: color, position: position)
    }
    
    override func possibleMoves(on board: [[ChessPiece?]]) -> [(Int, Int)] {
        var moves = [(Int, Int)]()
        let row = position.0
        let col = position.1
        
        // Các hướng di chuyển của quân Vua (8 hướng)
        let directions = [
            (1, 0), (0, 1), (-1, 0), (0, -1),  // lên, phải, xuống, trái
            (1, 1), (1, -1), (-1, 1), (-1, -1) // chéo phải trên, chéo trái trên, chéo phải dưới, chéo trái dưới
        ]
        
        for direction in directions {
            let newRow = row + direction.0
            let newCol = col + direction.1
            
            // Kiểm tra xem nước đi có nằm trong bàn cờ không
            if newRow >= 0 && newRow < 8 && newCol >= 0 && newCol < 8 {
                if let piece = board[newRow][newCol] {
                    // Nếu gặp quân cờ cùng màu thì không thể đi tiếp
                    if piece.color == self.color {
                        continue
                    }
                    // Nếu gặp quân đối thủ thì có thể ăn
                    moves.append((newRow, newCol))
                } else {
                    // Ô trống, có thể di chuyển
                    moves.append((newRow, newCol))
                }
            }
        }
        
        // Kiểm tra nhập thành
        if !hasMoved {
            // Nhập thành cánh vua (king-side castling)
            if let rook = board[row][7] as? Rook, !rook.hasMoved {
                if board[row][5] == nil && board[row][6] == nil {
                    moves.append((row, 6)) // Vị trí nhập thành
                }
            }
            
            // Nhập thành cánh hậu (queen-side castling)
            if let rook = board[row][0] as? Rook, !rook.hasMoved {
                if board[row][1] == nil && board[row][2] == nil && board[row][3] == nil {
                    moves.append((row, 2)) // Vị trí nhập thành
                }
            }
        }
        
        return moves
    }
}

