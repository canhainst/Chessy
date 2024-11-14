//
//  LottieView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 15/06/2024.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String
    var mode: Int

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView(name: filename)
        animationView.contentMode = .scaleAspectFit
        if mode == 0 {
            animationView.loopMode = .playOnce
        } else if mode == 1 {
            animationView.loopMode = .loop
        } else {
            animationView.loopMode = .autoReverse
        }
        
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}


#Preview {
    LottieView(filename: "fire.json", mode: 1)
}
