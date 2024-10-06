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
    
    @State private var region = ""
    @State private var avatar = "https://scontent.fhan4-5.fna.fbcdn.net/v/t39.30808-6/446651424_1681220119288938_4828402852445544478_n.jpg?_nc_cat=102&ccb=1-7&_nc_sid=5f2048&_nc_eui2=AeGvEhaUYJuwPLRQCg7lyf_fpCx3K8NjBGqkLHcrw2MEavwQ_SjguMUG0H6H6FgRcczBEYW2ma_FW13-2QC5KfOz&_nc_ohc=50VZ-XnUTZEQ7kNvgFz4OnB&_nc_ht=scontent.fhan4-5.fna&oh=00_AYCKUnjUS-oPZ8KpuIc9JnHA9UJoppuOL1UWFaJ5Ldp0Qw&oe=667C24D1"
    
    var currentUserID: String
    
    var body: some View {
        VStack {
            if profile.isLoading {
                LoadingView()
            } else if let user = profile.user {
                VStack {
                    Image("thachdau")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    
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
                                    HStack {
                                        HStack (spacing: 10) {
                                            ZStack {
                                                Image(systemName: "crown.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(index == 0 ? .yellow : (index == 1 ? .gray : (index == 2 ? .brown : .white)))
                                                Text("\(index + 1)")
                                                    .offset(y: 5)
                                            }
                                            
                                            AsyncImage(url: URL(string: avatar)) { phase in
                                                switch phase {
                                                case .empty:
                                                    // Placeholder while loading
                                                    BlankAvatarView(width: 50, height: 50)
                                                case .success(let image):
                                                    // Successfully loaded image
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: 40, height: 40)
                                                        .clipShape(Circle())
                                                case .failure:
                                                    // Failure loading image
                                                    BlankAvatarView(width: 50, height: 50)
                                                @unknown default:
                                                    BlankAvatarView(width: 50, height: 50)
                                                }
                                            }
                                            
                                            Text("\(user.name)")
                                                .font(.system(size: 20))
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("\(user.exp) Exp")
                                    }
                                    .padding(.horizontal, 20)
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
            profile.fetchUser(userID: currentUserID)
        }
        .padding(.top, 10)
    }
}

#Preview {
    ChessyChartsView(currentUserID: "WqzIRI2TH8XzS6fqOB7W5VROzaF2")
}
