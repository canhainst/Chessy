//
//  ChessyView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import SwiftUI

struct ChessyView: View {
    var currentUserID: String
    @Binding var challengerID: String
    @Binding var code: String
    @Binding var isPlayGame: Bool
    
    @State var roomCode: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                TabView {
                    ChessyHomeView(currentUserID: currentUserID, isPlayGame: $isPlayGame, roomCode: $code)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    ChessyFriendListView(currentUserID: currentUserID, isPlayGame: $isPlayGame, code: $code)
                        .tabItem {
                            Image(systemName: "person.2.fill")
                            Text("Friend")
                        }
                    ChessyChartsView(currentUserID: currentUserID)
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("Charts")
                        }
                    ChessyProfileView(currentUserID: currentUserID)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                }
                
                if !challengerID.isEmpty {
                    ChallengeRequest(isPlayGame: $isPlayGame, viewModel: ChallengeRequestViewModel(userID: challengerID))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                withAnimation {
                                    challengerID = ""
                                    code = ""
                                }
                            }
                        }
                        .transition(.move(edge: .top))
                }
            }
            .onChange(of: code) { newValue in
                if !code.isEmpty && roomCode != code {
                    roomCode = code
                }
            }
            .navigationDestination(isPresented: $isPlayGame) {
                GameplayView(roomCode: roomCode)
            }
        }
    }
}
