//
//  ChessyChartsView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import SwiftUI

struct ChessyChartsView: View {
    @StateObject var profile = ProfileViewModel()
    @StateObject var chart = ChartViewModel()
    
    @State private var region: String = "Asia"
    var currentUserID: String
    
    var body: some View {
        VStack {
            if profile.isLoading {
                LoadingView()
            } else if let user = profile.user {
                VStack {
                    Image(user.getBadgeImg())
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                    
                    Text(user.setRank())
                        .font(.system(size: 25))
                    
                    HStack {
                        VStack {
                            Text("Remaining season")
                                .font(.system(size: 20))
                            Text("--")
                                .fontWeight(.bold)
                        }
                        
                        Divider()
                            .frame(width: 1, height: 60)
                        
                        VStack {
                            Text("Experience points")
                                .font(.system(size: 20))
                            Text("\(user.exp) Exp")
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    
                    HStack(spacing: 20) {
                        Text("Region")
                            .padding()
                            .font(.system(size: 20))
                        
                        Picker("Region", selection: $region) {
                            Text("Asia").tag("Asia")
                            Text("Europe").tag("Europe")
                            Text("Africa").tag("Africa")
                            Text("Australia").tag("Australia")
                            Text("North America").tag("North America")
                            Text("South America").tag("South America")
                            Text("Antarctica").tag("Antarctica")
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal, 10)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    ScrollView {
                        if chart.isLoading {
                            ProgressView()
                        } else if let users = chart.users, !users.isEmpty {
                            let SortedUsers = chart.sortUserListByExp(users)
                            VStack {
                                ForEach(SortedUsers.indices, id: \.self) { index in
                                    let user = SortedUsers[index]
                                    userChart(user: user, index: index)
                                }
                            }
                        } else if let errorMessage = chart.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        } else {
                            Text("No user data available.")
                        }
                    }
                    .onAppear {
                        chart.fetchUsersListByRegion(region: user.region)
                    }
                    .onChange(of: region) { newRegion in
                        chart.fetchUsersListByRegion(region: newRegion)
                    }
                }
            } else if let errorMessage = profile.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                Text("No user data available.")
            }
            Spacer()
        }
        .onAppear {
            profile.fetchUser()
        }
        .padding(.top, 10)
    }
}

struct userChart: View {
    let user: User
    let index: Int
    
    var body: some View {
        HStack {
            HStack (spacing: 10) {
                ZStack {
                    if index < 3 {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 30))
                            .foregroundColor(index == 0 ? .yellow : (index == 1 ? .gray : (index == 2 ? .brown : .white)))
                    }
                    
                    Text("\(index + 1)")
                        .offset(y: 5)
                }
                .frame(width: 30)
                
                AvatarView(avatarLink: user.avatar ?? "", width: 50, height: 50)
                
                Text("\(user.name)")
                    .font(.system(size: 20))
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            Text("\(user.exp) Exp")
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ChessyChartsView(currentUserID: "WqzIRI2TH8XzS6fqOB7W5VROzaF2")
}
