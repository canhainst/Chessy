//
//  GameResultDialogView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 14/11/2024.
//

import SwiftUI
import FirebaseAuth

struct GameResultDialogView: View {
    let result: Int
    let roomID: String
    @Binding var showResult: Bool
    @Binding var rematchMsg: String
    
    @State private var opacity: Double = 0.0
    @State var onClick: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        if showResult {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea() // Làm mờ nền phía sau
                
                if !showResult {
                    FadeInTextView(text: "Checkmate", duration: 2.0)
                        .onAppear{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                showResult = true
                            }
                        }
                } else {
                    VStack {
                        switch result {
                        case 0:
                            LottieView(filename: "sad.json", mode: 1)
                                .frame(height: 100)
                            Text("Match result")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text("Lose")
                                .font(.title)
                                .foregroundColor(.black)
                        case 1:
                            LottieView(filename: "win.json", mode: 0)
                                .frame(height: 100)
                            Text("Match result")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text("Win")
                                .font(.title)
                                .foregroundColor(.black)
                        case 2:
                            LottieView(filename: "shakehands.json", mode: 0)
                                .frame(height: 100)
                            Text("Match result")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text("Draw")
                                .font(.title)
                                .foregroundColor(.black)
                        default:
                            EmptyView() // Add a default case for safety
                        }
                        
                        Button {
                            MatchModel.rematch(roomID: roomID)
                            onClick.toggle()
                        } label: {
                            Text(rematchMsg)
                                .font(.headline)
                                .foregroundColor(onClick ? .black : .white)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(onClick ? Color.gray : Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(onClick)
                        
                        Button {
                            showResult.toggle()
                            presentationMode.wrappedValue.dismiss()
                            MatchModel.exitGame(playerID: Auth.auth().currentUser!.uid, roomID: roomID)
                        } label: {
                            Text("Left the room")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(Color.gray)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .frame(width: 350)
                    .background(.white)
                    .cornerRadius(10)
                    .padding()
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.5)) {
                            opacity = 1.0 // Animate from 0 to 1 opacity
                        }
                    }
                }
            }
        }
    }
}

struct FadeInTextView: View {
    @State private var opacity: Double = 0.0
    
    var text: String
    var duration: Double // Duration of the fade-in effect in seconds

    var body: some View {
        Text(text)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .font(.system(size: 50))
            .padding()
            .opacity(opacity) // Bind opacity to the state variable
            .onAppear {
                withAnimation(.easeIn(duration: duration)) {
                    opacity = 1.0 // Animate from 0 to 1 opacity
                }
            }
    }
}
