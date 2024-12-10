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
    @State private var offsetY: CGFloat = 0
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

                    HStack (alignment: .top, spacing: 10) {
                        AvatarView(avatarLink: avatarE, width: 70, height: 70)
                        VStack (alignment: .leading, spacing: 10) {
                            Text(viewModel.playerE!.name)
                                .foregroundColor(.black)
                            HStack {
                                AsyncImage(url: URL(string: viewModel.playerE!.nation.flags.png)) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                         .frame(width: 30)
                                } placeholder: {
                                    ProgressView()
                                }
                                
                                Text("- \(viewModel.playerE!.region)")
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
                .offset(y: offsetY)
                .onAppear {
                    startCountdown()
                }
            }
            .animation(.easeInOut(duration: 0.5), value: offsetY)
        }
    }
    
    func startCountdown() {
        if viewModel.isHost! {
            MatchModel.setWhitePiece(roomID: viewModel.roomCode)
        }
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else if countdown == 1 {
                // Start the exit animation when countdown reaches 1
                withAnimation {
                    offsetY = -UIScreen.main.bounds.height
                }
                countdown -= 1
            } else {
                // When countdown reaches 0, invalidate timer and set player details
                timer.invalidate()
                playerEtmp = viewModel.playerEID!
                viewModel.setPlayerColor(roomCode: viewModel.roomCode)
                viewModel.listenRequest(userID: viewModel.playerID, friend: viewModel.playerEID!)
            }
        }
    }
}
