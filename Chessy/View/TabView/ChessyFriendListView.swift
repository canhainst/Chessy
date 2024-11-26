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
    let option: [String] = ["My friends", "Friend requests"]
    
    let listfriend: [(String?, User)?]
    let listAddFriend: [(String?, User)?]
    
    init(currentUserID: String) {
        let usertest = User(name: "Powder", age: 14, join: 0.0, region: "Asia", nation: Country(name: Country.Name(common: "abla"), flags: Country.Flag(png: "")), exp: 1000, followers: nil, following: nil, peak: 0, achievement: "")
        let avatartest = "https://image.civitai.com/xG1nkqKTMzGDvpLrqFT7WA/f092126e-4785-4945-9103-86cb3177c792/width=1200/f092126e-4785-4945-9103-86cb3177c792.jpeg"
        let friendtest = (avatartest, usertest)
        
        self.currentUserID = currentUserID
        self.selection = "My friends"
        self.listfriend = [friendtest, friendtest, friendtest, friendtest, friendtest, friendtest, friendtest]
        self.listAddFriend = [friendtest, friendtest, friendtest]
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
                
                ListfriendView(selectedView: selection, listfriend: listfriend, listAddFriend: listAddFriend)
            }
            .navigationTitle(selection)
        }
    }
}

struct ListfriendView: View {
    var selectedView: String
    
    let listfriend: [(String?, User)?]
    let listAddFriend: [(String?, User)?]
    
    var body: some View {
        switch selectedView {
        case "My friends":
            List(listfriend.indices, id: \.self) { id in
                friend(avatar: listfriend[id]!.0!, friend: listfriend[id]!.1)
            }
        case "Friend requests":
            List(listAddFriend.indices, id: \.self) { id in
                friendRequest(avatar: listAddFriend[id]!.0!, friend: listAddFriend[id]!.1)
            }
        default:
            Spacer()
        }
    }
}

struct friend: View {
    let avatar: String
    let friend: User
    
    var body: some View {
        HStack {
            AvatarView(avatarLink: avatar, width: 60, height: 60)
            VStack (alignment: .leading){
                HStack {
                    Text(friend.name)
                        .font(.headline)
                    AsyncImage(url: URL(string: friend.nation.flags.png)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                             .frame(width: 30)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                HStack {
                    Text(friend.region)
                    Text(" - ")
                    Text(friend.exp.formatted() + " exp")
                }
            }
            
            Spacer()
            
            Image(systemName: "ellipsis")
                .font(.title)
                .onTapGesture {
                    
                }
        }
    }
}

struct friendRequest: View {
    let avatar: String
    let friend: User
    
    var body: some View {
        HStack {
            AvatarView(avatarLink: avatar, width: 60, height: 70)
            VStack (alignment: .leading){
                HStack {
                    Text(friend.name)
                        .font(.headline)
                    AsyncImage(url: URL(string: friend.nation.flags.png)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                             .frame(width: 30)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                HStack {
                    Text(friend.region)
                    Text(" - ")
                    Text(friend.exp.formatted() + " exp")
                }
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .font(.title)
                .foregroundColor(.blue)
                .onTapGesture {
                    
                }
            
            Image(systemName: "x.circle")
                .font(.title)
                .foregroundColor(.red)
                .onTapGesture {
                    
                }
        }
    }
}

#Preview {
    ChessyFriendListView(currentUserID: "WqzIRI2TH8XzS6fqOB7W5VROzaF2")
}
