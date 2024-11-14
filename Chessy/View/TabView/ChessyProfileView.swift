//
//  ChessyProfileView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import SwiftUI

struct ChessyProfileView: View {
    var currentUserID: String
    
    @StateObject var ViewModel = LoginViewViewModel()
    @StateObject var profile = ProfileViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    @State private var avatar = "https://scontent.fsgn5-14.fna.fbcdn.net/v/t39.30808-6/329403231_474295524745893_3398994404525045455_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=6ee11a&_nc_ohc=a2CuVbMC_7sQ7kNvgF1OdR8&_nc_ht=scontent.fsgn5-14.fna&_nc_gid=Aj_52EeNMyhMviAl6CaI-Ob&oh=00_AYDRSPuFYsO-3jbvdVzrQZvgba2QD_I1GA56n0AQOlbnHA&oe=67051EAD"
    
    var body: some View {
        VStack {
            if profile.isLoading {
                LoadingView()
            } else if let user = profile.user {
                HStack {
                    AvatarView(avatarLink: avatar, width: 100, height: 100)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                    
                    Button {
                        ViewModel.logout()
                    } label: {
                        VStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title)
                        }
                        .foregroundColor(colorScheme == .light ? .black : .white)
                    }
                    .padding(.trailing, 20)
                }
                
                HStack (spacing: 20) {
                    Text(user.name)
                    Text("-")
                    Text(user.region)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .font(.system(size: 25))
                
                HStack {
                    Text(user.setRank())
                        
                    Circle()
                        .fill(colorScheme == .light ? Color.black : Color.white)
                        .frame(width: 10, height: 10)
                    
                    Text("Join in \(user.joinDateFormatted())")
                        .foregroundColor(Color.gray)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .font(.system(size: 20))
                
                HStack (spacing: 20) {
                    VStack {
                        Text("\(user.countFollowing())")
                        Text("Following")
                    }
                    
                    Divider()
                        .frame(width: 1, height: 60)
                    
                    VStack {
                        Text("\(user.countFollower())")
                        Text("Follower")
                    }
                }
                .padding(.top, 10)
                GeometryReader { geometry in
                    VStack {
                        Text("Overview")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .font(.system(size: 25))
                        HStack {
                            VStack {
                                Text("Total matches")
                                Text("\(user.totalMatches)")
                                    .font(.system(size: 25))
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.45)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .padding(.leading, geometry.size.width * 0.01)
                            
                            VStack {
                                Text("Winrate")
                                Text("\(user.Winrate())%")
                                    .font(.system(size: 25))
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.45)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                        }
                        .font(.system(size: 20))
                        
                        HStack {
                            VStack {
                                Text("Win streak")
                                Text("\(user.winStreak)")
                                    .font(.system(size: 25))
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.45)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .padding(.leading, geometry.size.width * 0.01)
                            
                            VStack {
                                Text("Peak")
                                if(user.peak == 0){
                                    Text("--")
                                        .font(.system(size: 25))
                                        .fontWeight(.bold)
                                        .foregroundColor(colorScheme == .light ? .black : .white)
                                } else {
                                    Text("\(user.peak)")
                                        .font(.system(size: 25))
                                        .fontWeight(.bold)
                                        .foregroundColor(user.peak <= 100 ? (user.peak <= 10 ? Color.red: Color.orange) : (colorScheme == .light ? .black : .white))
                                }
                            }
                            .padding()
                            .frame(width: geometry.size.width * 0.45)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                        }
                        .font(.system(size: 20))
                        
                        Text("Achievement")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .font(.system(size: 25))
                            .padding(.top, 20)
                        
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

struct BlankAvatarView: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        ZStack {
            // Circle background
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: width, height: height)
            
            // Placeholder text or icon
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: width * 0.5, height: height * 0.5)
                .foregroundColor(.gray)
        }
    }
}

struct AvatarView: View {
    let avatarLink: String
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: avatarLink)) { phase in
            switch phase {
            case .empty:
                // Placeholder while loading
                BlankAvatarView(width: width, height: height)
            case .success(let image):
                // Successfully loaded image
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipShape(Circle())
            case .failure:
                // Failure loading image
                BlankAvatarView(width: width, height: height)
            @unknown default:
                BlankAvatarView(width: width, height: height)
            }
        }
        .frame(alignment: .leading)
    }
}

#Preview {
    ChessyProfileView(currentUserID: "WqzIRI2TH8XzS6fqOB7W5VROzaF2")
}

