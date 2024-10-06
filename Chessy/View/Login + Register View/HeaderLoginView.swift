//
//  HeaderLoginView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 04/06/2024.
//

import SwiftUI

struct HeaderLoginView: View {
    let Tittle: String
    let Subtittle: String
    let angle: Double
    let keyboardHeight: CGFloat
    let BackgroundColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundColor(BackgroundColor)
                .rotationEffect(Angle(degrees: angle))
            VStack {
                Text(Tittle)
                    .font(.system(size: 50))
                    .foregroundColor(Color.white)
                    .scaleEffect(keyboardHeight > 0 ? 0.8 : 1)
                    .offset(y: (keyboardHeight > 0 ? 20 : 0))
                    .bold()

                
                Text(Subtittle)
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                    .opacity(keyboardHeight > 0 ? 0 : 1)
            }
            .padding(.top, keyboardHeight > 0 ? 130 : 30)
        }
        .frame(width: UIScreen.main.bounds.width * 3, height: 300)
        .offset(y: keyboardHeight > 0 ? -50 : -100)
    }
}

#Preview {
    HeaderLoginView(Tittle: "Tittle", Subtittle: "Subtittle", angle: 10, keyboardHeight: 0, BackgroundColor: .blue)
}
