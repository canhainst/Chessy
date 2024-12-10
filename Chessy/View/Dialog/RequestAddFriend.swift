//
//  RequestAddFriend.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/12/2024.
//

import SwiftUI

struct RequestAddFriend: View {
    let name: String
    let viewModel: ChessGameViewModel
    
    var body: some View {
        ZStack {
            VStack {
                Text("\(name)")
                    .font(.body)
                    .fontWeight(.bold)
                Text("Sent you a friend request")
                
                HStack {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            User.deleteRequest(userID: viewModel.playerID, deleteID: viewModel.playerEID!)
                            User.recallRequest(userID: viewModel.playerEID!, deleteID: viewModel.playerID)
                            User.addFriend(userID: viewModel.playerID, friendID: viewModel.playerEID!)
                            User.addFriend(userID: viewModel.playerEID!, friendID: viewModel.playerID)
                        }
                    Image(systemName: "x.circle")
                        .font(.title2)
                        .foregroundColor(.red)
                        .onTapGesture {
                            User.deleteRequest(userID: viewModel.playerID, deleteID: viewModel.playerEID!)
                            User.recallRequest(userID: viewModel.playerEID!, deleteID: viewModel.playerID)
                        }
                }
                .padding(.top, 3)
            }
            .frame(width: 200)
            .padding()
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
            )
            
            Image(systemName: "x.circle")
                .font(.title3)
                .foregroundColor(.black)
                .offset(x: 95, y: -38)
                .onTapGesture {
                    viewModel.isFriendRequest = false
                }
        }
    }
}
