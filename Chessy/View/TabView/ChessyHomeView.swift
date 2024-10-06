//
//  ChessyHomeView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/06/2024.
//

import SwiftUI

struct ChessyHomeView: View {
    var currentUserID: String
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Play Chess Online on the #1 Application")
                    .font(.title)
                
                Text("100 Games Today")
                Text("11 Playing Now")
                
                Button {
                } label: {
                    Text("Find match")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                Button {
                } label: {
                    Text("Play with friend")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
}

#Preview {
    ChessyHomeView(currentUserID: "WqzIRI2TH8XzS6fqOB7W5VROzaF2")
}
