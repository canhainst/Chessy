//
//  AvatarView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/12/2024.
//

import SwiftUI

struct AvatarView: View {
    let avatarLink: String
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: avatarLink)) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(Circle())
        } placeholder: {
            BlankAvatarView(width: width, height: height)
        }
        .frame(alignment: .leading)
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
