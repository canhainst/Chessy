//
//  ChessyFriendListView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import SwiftUI

struct ChessyFriendListView: View {
    var currentUserID: String
    @Binding var isPlayGame: Bool
    @Binding var code: String

    @State var selection: String = "Friends List"
    let option: [String] = ["Friends List", "Requests"]
    
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
                
                ListfriendView(selectedView: selection, currentUserID: currentUserID, isPlayGame: $isPlayGame, code: $code)
            }
            .navigationTitle(selection)
        }
    }
}

struct ListfriendView: View {
    var selectedView: String
    var currentUserID: String
    @Binding var isPlayGame: Bool
    @Binding var code: String
    
    @State private var showFriendRequests: Bool = true
    @State private var showRequestsSent: Bool = true
    
    @State private var showSnackbar = false
    @State private var message = ""
    @State private var typeSnackbar = ""
    
    @ObservedObject var viewModel = FriendsListViewModel()
    
    var body: some View {
        switch selectedView {
        case "Friends List":
            if viewModel.listFriends.isEmpty {
                Spacer()
                Text("Let's make some friends")
                LottieView(filename: "sad.json", mode: 1)
                    .frame(height: 70)
                Spacer()
            } else {
                ZStack {
                    List(viewModel.listFriends.indices, id: \.self) { id in
                        Friend(currentUserID: currentUserID, user: viewModel.listFriends[id]!, viewModel: viewModel, showSnackbar: $showSnackbar, message: $message, typeSnackbar: $typeSnackbar, isPlayGame: $isPlayGame, roomID: $code)
                    }
                    if showSnackbar {
                        Snackbar(type: typeSnackbar, message: message)
                    }
                }
            }
        case "Requests":
            ZStack {
                VStack {
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
                            Request(currentUserID: currentUserID, user: viewModel.listRequests[id]!, showSnackbar: $showSnackbar, message: $message, typeSnackbar: $typeSnackbar)
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
                            RequestsSent(currentUserID: currentUserID, user: viewModel.listRequestsSent[id]!, viewModel: viewModel, showSnackbar: $showSnackbar, message: $message, typeSnackbar: $typeSnackbar)
                        }
                        .transition(.slide)
                    }
                    
                    Spacer()
                }
                if showSnackbar {
                    Snackbar(type: typeSnackbar, message: message)
                }
            }
        default:
            Spacer()
        }
    }
}
