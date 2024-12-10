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
    @State private var isChallenged = false
    @State private var responsed = false
    
    @Binding var showSnackbar: Bool
    @Binding var message: String
    @Binding var typeSnackbar: String
    @Binding var isPlayGame: Bool
    @Binding var roomID: String
    
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
                    
                    withAnimation {
                        typeSnackbar = "error"
                        message = "You have deleted a friend"
                        showSnackbar = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showSnackbar = false
                        }
                    }
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

            Button(isChallenged ? "Waiting" : "Challenge") {
                MatchModel.isUserInGame(userID: user.id) { isInGame in
                    if !isInGame {
                        responsed = false
                        withAnimation {
                            let newChallenge = Challenge(challengerID: currentUserID, code: nil, isAccepted: nil)
                            Challenge.challengeTo(userID: user.id, challenge: newChallenge) { success in
                                if success {
                                    typeSnackbar = "normal"
                                    message = "You have sent a challenge to \(user.name)"
                                    showSnackbar = true
                                    isChallenged = true
                                } else {
                                    typeSnackbar = "important"
                                    message = "Failed to send challenge"
                                    showSnackbar = true
                                }
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showSnackbar = false
                            }
                        }
                        
                        Challenge.listenForAcceptance(userID: user.id) { isAccepted in
                            if isAccepted {
                                roomID = generateRandomString()
                                Challenge.setRoomCode(userID: user.id, roomID: roomID)
                                
                                let newMatch = MatchModel(gameID: UUID(), roomID: roomID, playerID: [currentUserID, nil], pieceMoves: [], winnerID: nil, host: currentUserID, whitePiece: nil, rematch: nil, type: "Normal")
                                
                                MatchModel.insertNewGame(matchModel: newMatch) { success in
                                    if success {
                                        isPlayGame = true
                                    } else {
                                        withAnimation {
                                            typeSnackbar = "important"
                                            message = "Failed to set up Gameplay"
                                            showSnackbar = true
                                            isChallenged = false
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            withAnimation {
                                                showSnackbar = false
                                            }
                                        }
                                    }
                                }
                            } else {
                                Challenge.cancelChallenge(userID: user.id)
                                withAnimation {
                                    isChallenged = false
                                    typeSnackbar = "important"
                                    message = "The player refused the challenge."
                                    showSnackbar = true
                                    responsed = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showSnackbar = false
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            isChallenged = false
                            typeSnackbar = ""
                            message = "Not responding"
                            showSnackbar = !responsed
                            Challenge.cancelChallenge(userID: user.id)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showSnackbar = false
                                }
                            }
                        }
                    } else {
                        withAnimation {
                            typeSnackbar = "important"
                            message = "This player are in a game"
                            showSnackbar = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showSnackbar = false
                            }
                        }
                    }
                }
            }
            .tint(isChallenged ? .gray : .blue) // Màu xanh cho nút follow
            .disabled(isChallenged)
        }
    }
    
    func generateRandomString(length: Int = 6) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
}

struct RequestsSent: View {
    let currentUserID: String
    let user: User
    let viewModel: FriendsListViewModel
    
    @Binding var showSnackbar: Bool
    @Binding var message: String
    @Binding var typeSnackbar: String
        
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
                withAnimation {
                    typeSnackbar = ""
                    message = "Friend request revoked"
                    showSnackbar = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showSnackbar = false
                    }
                }
            }
            .tint(.gray) // Màu đỏ cho nút delete
        }
    }
}

struct Request: View {
    let currentUserID: String
    let user: User
    
    @Binding var showSnackbar: Bool
    @Binding var message: String
    @Binding var typeSnackbar: String
    
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
                            typeSnackbar = "normal"
                            message = "Friend request accepted"
                            showSnackbar = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showSnackbar = false
                            }
                        }
                    }
                
                Image(systemName: "x.circle")
                    .font(.title)
                    .foregroundColor(.red)
                    .onTapGesture {
                        User.deleteRequest(userID: currentUserID, deleteID: user.id)
                        User.recallRequest(userID: user.id, deleteID: currentUserID)
                        withAnimation {
                            typeSnackbar = ""
                            message = "Friend request rejected"
                            showSnackbar = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showSnackbar = false
                            }
                        }
                    }
            }
        }
    }
}
