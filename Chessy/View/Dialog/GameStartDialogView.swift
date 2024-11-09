//
//  GameStartDialogView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 09/11/2024.
//

import SwiftUI

struct GameStartDialogView: View {
    let avatarE: String
    let viewModel: ChessGameViewModel
        
    @State private var countdown = 5
    @State var playerEtmp: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        if playerEtmp != viewModel.playerEID  {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea() // Làm mờ nền phía sau
                
                VStack {
                    Text("Your opponent is")
                        .font(.title)
                        .foregroundColor(.black)

                    HStack {
                        AvatarView(avatarLink: avatarE, width: 70, height: 70)
                        VStack (alignment: .leading, spacing: 10) {
                            Text(viewModel.playerE!.name)
                                .foregroundColor(.black)
                            HStack {
                                Image("VN")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit) // Giữ tỷ lệ ảnh
                                    .frame(width: 30)
                                Text(" - \(viewModel.playerE!.region)")
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                    }
                    .frame(width: 250)
                    .padding()
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0.5)
    
                    Text("The game will start in \(countdown) seconds.")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding()
                .frame(width: 350)
                .background(.white)
                .cornerRadius(10)
                .padding()
                .onAppear {
                    startCountdown()
                }
            }
        }
    }
    
    func startCountdown() {
        if viewModel.isHost! {
            MatchModel.setWhitePiece(roomID: viewModel.roomCode)
        }
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                playerEtmp = viewModel.playerEID!
                viewModel.setPlayerColor(roomCode: viewModel.roomCode)
            }
        }
    }
}

#Preview {
    GameStartDialogView(avatarE: "https://scontent.fsgn5-15.fna.fbcdn.net/v/t39.30808-1/329403231_474295524745893_3398994404525045455_n.jpg?stp=dst-jpg_s320x320&_nc_cat=101&ccb=1-7&_nc_sid=0ecb9b&_nc_ohc=KWc8e4ajb_kQ7kNvgFKv9O1&_nc_ht=scontent.fsgn5-15.fna&_nc_gid=AsElcq77z_KMcshyn3x5587&oh=00_AYCnMSrtUC7eOKxmjZbybn9fTggSMOi9sk27Ia68sgrbDw&oe=670BE6EB", viewModel: ChessGameViewModel(), playerEtmp: "")
}
