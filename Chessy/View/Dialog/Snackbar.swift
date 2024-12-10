//
//  Snackbar.swift
//  Chessy
//
//  Created by Nguyễn Thành on 07/12/2024.
//

import SwiftUI

struct Snackbar: View {
    let type: String
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(message)
                    .foregroundColor(.white)
                    .padding()
                Spacer()
            }
            .background(type == "normal" ? Color.green : (type == "important" ? Color.red : Color.gray))
            .cornerRadius(8)
            .padding()
            .shadow(radius: 4)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    Snackbar(type: "normal", message: "This is a message")
}
