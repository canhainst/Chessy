//
//  Knight.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import Foundation

class Knight: ChessPiece {
    override init(color: PlayerColor, position: (Int, Int)) {
        super.init(color: color, position: position)
    }
    
    // Hàm tính toán các nước đi hợp lệ cho quân Mã
    override func possibleMoves(on board: [[ChessPiece?]]) -> [(Int, Int)] {
        var moves = [(Int, Int)]()
        let row = position.0
        let col = position.1
        
        // Các nước đi có thể của quân Mã (L-shaped moves)
        let possibleOffsets = [
            (2, 1), (2, -1), (-2, 1), (-2, -1),
            (1, 2), (1, -2), (-1, 2), (-1, -2)
        ]
        
        // Kiểm tra tất cả các tọa độ mới mà Mã có thể di chuyển đến
        for offset in possibleOffsets {
            let newRow = row + offset.0
            let newCol = col + offset.1
            
            // Kiểm tra xem nước đi có nằm trong bàn cờ và không có quân cờ cùng màu
            if isValidMove(newRow, newCol, board: board) {
                moves.append((newRow, newCol))
            }
        }
        
        return moves
    }
    
    // Kiểm tra xem nước đi có hợp lệ không
    private func isValidMove(_ row: Int, _ col: Int, board: [[ChessPiece?]]) -> Bool {
        // Nước đi nằm trong bàn cờ
        guard row >= 0, row < 8, col >= 0, col < 8 else { return false }
        
        // Kiểm tra xem ô mới có trống hoặc có quân cờ đối phương (có thể ăn quân)
        if let piece = board[row][col] {
            return piece.color != self.color  // Quân đối phương
        }
        
        return true  // Ô trống
    }
}
