//
//  ChessyView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import SwiftUI

struct ChessyView: View {
    var currentUserID: String
    
    var body: some View {
        TabView {
            ChessyHomeView(currentUserID: currentUserID)
                .tabItem {
                    Image(systemName: "house.fill" )
                    Text("Home")
                }
            ChessyFriendListView(currentUserID: currentUserID)
                .tabItem {
                    Image(systemName: "person.2.fill" )
                    Text("Friend")
                }
            ChessyChartsView(currentUserID: currentUserID)
                .tabItem {
                    Image(systemName: "chart.bar.fill" )
                    Text("Charts")
                }
            ChessyProfileView(currentUserID: currentUserID)
                .tabItem {
                    Image(systemName: "person.fill" )
                    Text("Profile")
                }
        }
    }
}

#Preview {
    ChessyView(currentUserID: "WqzIRI2TH8XzS6fqOB7W5VROzaF2")
}
