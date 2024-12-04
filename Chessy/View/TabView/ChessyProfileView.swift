//
//  ChessyProfileView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import SwiftUI

struct ChessyProfileView: View {
    let currentUserID: String
    
    @StateObject var ViewModel = LoginViewViewModel()
    @StateObject var profile = ProfileViewModel()
    
    var body: some View {
        ScrollView {
            if profile.isLoading {
                LoadingView()
            } else if let user = profile.user {
                ProfileView(currentUserID: currentUserID, user: user, ViewModel: ViewModel, profile: profile)
            } else if let errorMessage = profile.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                Text("No user data available.")
            }
        }
        .onAppear{
            profile.fetchMatchHistory()
            profile.fetchUser()
        }
    }
}

struct ProfileView: View {
    let currentUserID: String
    let user: User
    let ViewModel: LoginViewViewModel
    let profile: ProfileViewModel
        
    @State private var sortBy: String = "All"
    @State private var isPublic: Bool = true
    @State private var viewAvatar: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            VStack {
                // Avatar & Logout button
                HStack {
                    VStack {
                        AvatarView(avatarLink: user.avatar ?? "", width: 70, height: 70)
                            .onTapGesture {
                                withAnimation {
                                    viewAvatar.toggle()
                                }
                            }
                        
                        Text(isPublic ? "Public" : "Private")
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .onTapGesture {
                                let status = isPublic
                                User.toggleStatus(userID: currentUserID, status: !status)
                                isPublic.toggle()
                            }
                            .onAppear {
                                isPublic = user.isPublic
                            }
                    }
                    
                    Spacer()
                    
                    Button {
                        ViewModel.logout()
                    } label: {
                        VStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title)
                        }
                        .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                }
                
                // User info
                HStack (spacing: 20) {
                    Text(user.name)
                    AsyncImage(url: URL(string: user.nation.flags.png)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                             .frame(width: 30)
                    } placeholder: {
                        ProgressView()
                    }
                    Text("-")
                    Text(user.region)
                    
                    Spacer()
                }
                .font(.system(size: 25))
                
                HStack {
                    Text(user.setRank())
                        
                    Circle()
                        .fill(colorScheme == .light ? Color.black : Color.white)
                        .frame(width: 10, height: 10)
                    
                    Text("Join in \(user.joinDateFormatted())")
                        .foregroundColor(Color.gray)
                    
                    Spacer()
                }
                .font(.system(size: 20))
                
                VStack {
                    Text("\(profile.friendsCount ?? 0)")
                    Text("Friends")
                }
                .padding(.top, 10)
                
                Text("Overview")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 25))
                
                // Overview Section
                GeometryReader { geometry in
                    VStack {
                        HStack {
                            VStack {
                                Text("Total matches")
                                Text("\(profile.matchHistoryList.count)")
                                    .font(.system(size: 25))
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            
                            VStack {
                                Text("Winrate")
                                Text("\(profile.winrate(playerID: currentUserID))")
                                    .font(.system(size: 25))
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                        }
                        .font(.system(size: 20))
                        
                        // More Overview Information...
                        HStack {
                            VStack {
                                Text("Win streak")
                                Text("\(profile.winstreak(playerID: currentUserID))")
                                    .font(.system(size: 25))
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            
                            VStack {
                                Text("Peak")
                                let peak = profile.getPeakStreak(playerID: currentUserID, currentPeak: user.peak)
                                if(peak == 0){
                                    Text("--")
                                        .font(.system(size: 25))
                                        .fontWeight(.bold)
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                } else {
                                    Text("\(peak)")
                                        .font(.system(size: 25))
                                        .fontWeight(.bold)
                                        .foregroundColor(user.peak <= 100 ? (user.peak <= 10 ? Color.red: Color.orange) : (colorScheme == .light ? .black : .white))
                                }
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                        }
                        .font(.system(size: 20))
                    }
                }
                Text("Achievement")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 25))
                    .padding(.top, 200)
                
                Text("\(user.achievement != "" ? user.achievement : "You haven't achieved any titles yet")")
                    .font(.system(size: 20))
                    .padding(.top, 5)
                
                if(user.achievement != ""){
                    LottieView(filename: "fire.json", mode: 1)
                        .frame(height: 70)
                } else {
                    LottieView(filename: "sad.json", mode: 1)
                        .frame(height: 70)
                }
                
                HStack (alignment: .bottom){
                    Text("Match history")
                        .font(.system(size: 25))
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    Picker("Region", selection: $sortBy) {
                        Text("All").tag("All")
                        Text("Rank").tag("Rank")
                        Text("Normal").tag("Normal")
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                
                if profile.isLoadingHistory {
                    LoadingView()
                } else if let errorMessage = profile.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    let filteredHistoryList = profile.getFilteredHistoryList(sortBy: sortBy)
                    if !filteredHistoryList.isEmpty {
                        ForEach(filteredHistoryList.indices, id: \.self) { index in
                            MatchHistoryView(currentUserID: currentUserID, MatchHistory: filteredHistoryList[index]!)
                        }
                        .padding(.top, 5)
                    } else {
                        Text("You have not played any game yet.")
                            .font(.system(size: 20))
                            .padding(.top, 5)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            if viewAvatar {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea() // Làm mờ nền phía sau
                        .onTapGesture {
                            withAnimation {
                                viewAvatar = false
                            }
                        }
                    
                    VStack (spacing: 20){
                        AvatarView(avatarLink: user.avatar ?? "", width: 200, height: 200)
                            .transition(.scale)
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        
                        Button {
                            
                        } label: {
                            Text("Upload Image")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 160)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }

                    }
                }
                .offset(y: -100)
                .frame(height: .infinity)
            }
        }
    }
}

struct MatchHistoryView: View {
    let currentUserID: String
    let MatchHistory: MatchHistoryModel
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                Text(MatchHistory.type + " match")
                
                if let Point = MatchHistory.historyPoint.first(where: { $0.playerID == currentUserID }) {
                    if Point.point >= 0 {
                        Text("+ \(Point.point) exp")
                    } else {
                        Text("- \(abs(Point.point)) exp")
                    }
                }
                
                Text("\(formatDate(time: MatchHistory.timestamp))")
            }
            Spacer()
            Text(MatchHistory.winnerID == currentUserID ? "WIN" : "LOSE")
                .font(.title)
                .foregroundStyle(MatchHistory.winnerID == currentUserID ? (colorScheme == .light ? Color.black : Color.white) : Color.red)
        }
    }
}

func formatDate(time: Double) -> String{
    let date = Date(timeIntervalSince1970: time)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd:MM:yyyy HH:mm:ss"
    return dateFormatter.string(from: date)
}

#Preview {
    ChessyProfileView(currentUserID: "WlwXEagO4LX4BKiCbap8HZVxhc52")
}

