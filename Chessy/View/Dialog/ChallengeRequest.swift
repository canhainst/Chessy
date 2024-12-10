//
//  ChallengRequest.swift
//  Chessy
//
//  Created by Nguyễn Thành on 07/12/2024.
//

import SwiftUI
import FirebaseAuth

struct ChallengeRequest: View {
    @State private var showAnimation = false
    @Binding var isPlayGame: Bool
    @ObservedObject var viewModel: ChallengeRequestViewModel
    
    var body: some View {
        if viewModel.isChallenged {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack {
                    HStack(spacing: 20) {
                        AvatarView(avatarLink: viewModel.userChallenge?.avatar ?? "", width: 50, height: 50)
                        VStack(alignment: .leading, spacing: 0) {
                            Text(viewModel.userChallenge?.name ?? "Unknown")
                                .fontWeight(.bold)
                                .font(.title2)
                                .foregroundColor(.black)
                            HStack {
                                
                                Text(viewModel.userChallenge?.setRank() ?? "Rank: N/A")
                                    .foregroundColor(.black)
                                Image(viewModel.userChallenge?.getBadgeImg() ?? "")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 0)
                            }
                        }
                        Spacer()
                        
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    Text("Would you like to play a game of chess with me?")
                        .font(.title2)
                        .foregroundColor(.black)
                    HStack {
                        Button {
                            Challenge.replyChallenge(userID: Auth.auth().currentUser!.uid, isAccept: false)
                            withAnimation {
                                viewModel.isChallenged = false
                            }
                        } label: {
                            Text("Later")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 160)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        Button {
                            // Hành động khi người dùng chấp nhận thử thách
                            let currentUserID = Auth.auth().currentUser!.uid
                            Challenge.replyChallenge(userID: currentUserID, isAccept: true)
                        } label: {
                            Text("Get go")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 160)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                }
                .frame(width: 320)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .offset(y: showAnimation ? -240 : -1000)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showAnimation = true
                    }
                }
                .onDisappear {
                    showAnimation = false
                }
            }
        }
    }
}
