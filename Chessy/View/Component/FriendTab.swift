//
//  FriendTab.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/12/2024.
//

import SwiftUI

struct Friend: View {
    let currentUserID: String
    let user: User
    let viewModel: FriendsListViewModel
    
    @State private var showAlert = false
    
    var body: some View {
        HStack {
            AvatarView(avatarLink: user.avatar ?? "", width: 60, height: 60)
            VStack (alignment: .leading){
                HStack {
                    Text(user.name)
                        .font(.headline)
                    AsyncImage(url: URL(string: user.nation.flags.png)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                             .frame(width: 30)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                HStack {
                    Text(user.region)
                    Text("-")
                    Text(user.setRank())
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.headline)
                .onTapGesture {
                    
                }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirm"),
                message: Text("Delete friend?"),
                primaryButton: .default(Text("Delete")) {
                    viewModel.deleteFriend(user: user)
                    User.deleteFriend(userID: currentUserID, friendID: user.id)
                    User.deleteFriend(userID: user.id, friendID: currentUserID)
                },
                secondaryButton: .cancel() {
                }
            )
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Unfriend") {
                showAlert = true
            }
            .tint(.red) // Màu đỏ cho nút delete

            Button("Challenge") {

            }
            .tint(.blue) // Màu xanh cho nút follow
        }
    }
}

struct RequestsSent: View {
    let currentUserID: String
    let user: User
    let viewModel: FriendsListViewModel
        
    var body: some View {
        HStack {
            AvatarView(avatarLink: user.avatar ?? "", width: 60, height: 60)
            VStack (alignment: .leading){
                HStack {
                    Text(user.name)
                        .font(.headline)
                    AsyncImage(url: URL(string: user.nation.flags.png)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                             .frame(width: 30)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                HStack {
                    Text(user.region)
                    Text("-")
                    Text(user.setRank())
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.headline)
                .onTapGesture {
                    
                }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Recall") {
                User.deleteRequest(userID: user.id, deleteID: currentUserID)
                User.recallRequest(userID: currentUserID, deleteID: user.id)
            }
            .tint(.gray) // Màu đỏ cho nút delete
        }
    }
}

struct Request: View {
    let currentUserID: String
    let user: User
    
    @State private var isAccepted: Bool = false
        
    var body: some View {
        HStack {
            AvatarView(avatarLink: user.avatar ?? "", width: 60, height: 60)
            VStack (alignment: .leading){
                HStack {
                    Text(user.name)
                        .font(.headline)
                    AsyncImage(url: URL(string: user.nation.flags.png)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                             .frame(width: 30)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                HStack {
                    Text(user.region)
                    Text("-")
                    Text(user.setRank())
                }
            }
            
            Spacer()
            
            if isAccepted {
                Text("Accepted")
                    .font(.system(size: 10, weight: .medium))
                    .padding(.horizontal, 7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .transition(.scale)
            } else {
                Image(systemName: "checkmark.circle")
                    .font(.title)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        User.deleteRequest(userID: currentUserID, deleteID: user.id)
                        User.recallRequest(userID: user.id, deleteID: currentUserID)
                        User.addFriend(userID: currentUserID, friendID: user.id)
                        User.addFriend(userID: user.id, friendID: currentUserID)
                        
                        withAnimation {
                            isAccepted.toggle()
                        }
                    }
                
                Image(systemName: "x.circle")
                    .font(.title)
                    .foregroundColor(.red)
                    .onTapGesture {
                        User.deleteRequest(userID: currentUserID, deleteID: user.id)
                        User.recallRequest(userID: user.id, deleteID: currentUserID)
                    }
            }
        }
    }
}
