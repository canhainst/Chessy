//
//  ChessyFriendListView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import SwiftUI

struct ChessyFriendListView: View {
    var currentUserID: String
    
    @State var selection: String
    let option: [String] = ["Friends List", "Requests"]
    
    init(currentUserID: String) {
        self.currentUserID = currentUserID
        self.selection = "Friends List"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker(selection: $selection, label: Text("Picker")) {
                    ForEach(option, id: \.self) { item in
                        Text(item)
                            .tag(item)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                ListfriendView(selectedView: selection, currentUserID: currentUserID)
            }
            .navigationTitle(selection)
        }
    }
}

struct ListfriendView: View {
    var selectedView: String
    var currentUserID: String
    
    @State private var showFriendRequests: Bool = true
    @State private var showRequestsSent: Bool = true
    @ObservedObject var viewModel = FriendsListViewModel()
    
    var body: some View {
        switch selectedView {
        case "Friends List":
            if viewModel.listFriends.isEmpty {
                Spacer()
                Text("Let make some friends")
                LottieView(filename: "sad.json", mode: 1)
                    .frame(height: 70)
                Spacer()
            } else {
                List(viewModel.listFriends.indices, id: \.self) { id in
                    FriendList(currentUserID: currentUserID, user: viewModel.listFriends[id]!, viewModel: viewModel)
                }
            }
        case "Requests":
            HStack {
                Text("Friend request")
                Spacer()
                Image(systemName: showFriendRequests ? "chevron.down" : "chevron.right")
                    .font(.headline)
            }
            .padding()
            .background(Color.gray.opacity(0.5))
            .onAppear {
                if viewModel.listRequests.isEmpty {
                    showFriendRequests = false
                }
            }
            .onTapGesture {
                withAnimation {
                    showFriendRequests.toggle()
                }
            }
            
            if showFriendRequests {
                List(viewModel.listRequests.indices, id: \.self) { id in
                    Request(currentUserID: currentUserID, user: viewModel.listRequests[id]!)
                }
                .transition(.slide)
            }
            
            HStack {
                Text("Request sent")
                Spacer()
                Image(systemName: showRequestsSent ? "chevron.down" : "chevron.right")
                    .font(.headline)
            }
            .padding()
            .background(Color.gray.opacity(0.5))
            .onAppear {
                if viewModel.listRequestsSent.isEmpty {
                    showRequestsSent = false
                }
            }
            .onTapGesture {
                withAnimation {
                    showRequestsSent.toggle()
                }
            }
            
            if showRequestsSent {
                List(viewModel.listRequestsSent.indices, id: \.self) { id in
                    RequestsSent(currentUserID: currentUserID, user: viewModel.listRequestsSent[id]!, viewModel: viewModel)
                }
                .transition(.slide)
            }
            
            Spacer()
            
            
        default:
            Spacer()
        }
    }
}

struct FriendList: View {
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

#Preview {
    ChessyFriendListView(currentUserID: "WqzIRI2TH8XzS6fqOB7W5VROzaF2")
}
