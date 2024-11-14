//
//  GameResultDialogView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 14/11/2024.
//

import SwiftUI

struct GameResultDialogView: View {
    let result: Int

    @State private var showResult: Bool = false
    @State private var opacity: Double = 0.0
    
    var body: some View {
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
                        
                    } label: {
                        Text("New Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color.blue)
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

struct FadeInTextView: View {
    @State private var opacity: Double = 0.0
    
    var text: String
    var duration: Double // Duration of the fade-in effect in seconds

    var body: some View {
        Text(text)
            .font(.title)
            .padding()
            .opacity(opacity) // Bind opacity to the state variable
            .onAppear {
                withAnimation(.easeIn(duration: duration)) {
                    opacity = 1.0 // Animate from 0 to 1 opacity
                }
            }
    }
}

#Preview {
    GameResultDialogView(result: 0)
}
