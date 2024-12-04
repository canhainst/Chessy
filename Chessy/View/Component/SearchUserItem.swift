//
//  SearchUserItem.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/12/2024.
//

import SwiftUI

struct SearchUserItem: View {
    let user: User
    
    var body: some View {
        HStack {
            AvatarView(avatarLink: user.avatar ?? "", width: 40, height: 40)
            Text(user.name)
                .font(.headline)
            Spacer()
            Image(systemName: "ellipsis")
                .font(.headline)
                .onTapGesture {
                    
                }
        }
    }
}
