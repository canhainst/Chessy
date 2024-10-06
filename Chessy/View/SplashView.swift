//
//  SplashView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 22/06/2024.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: -20) {
                LottieView(filename: "splash_anim.json")
                    .frame(height: 300)

                Text("Chessy")
                    .font(.system(size: 40))
                    .fontWeight(.bold)
            }
            .offset(y: -20)
        }
    }
}

#Preview {
    SplashView()
}
