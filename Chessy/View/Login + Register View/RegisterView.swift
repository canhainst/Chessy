//
//  RegisterView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 04/06/2024.
//

import SwiftUI

struct RegisterView: View {
    @State private var isValidInput = false
    @State private var keyboardHeight: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    @StateObject var ViewModel = LoginViewViewModel()
    @StateObject var Register = RegisterViewViewModel()
    
    var body: some View {
        NavigationView{
            VStack{
                // Header
                HeaderLoginView(Tittle: "Resgiter",
                                Subtittle: "Let's fight for honor",
                                angle: 10, keyboardHeight: keyboardHeight,
                                BackgroundColor: Color.green)
                .offset(y: -30)
                RegisterInputView()
                
                Spacer()
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                    let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
                    let height = value.height
                    withAnimation {
                        self.keyboardHeight = height
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                    withAnimation {
                        self.keyboardHeight = 0
                    }
                }
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
            .onChange(of: Register.emailOrPhone, perform: { newValue in
                validateInput(newValue)
            })
        }
    }
    
    func validateInput(_ input: String) {
//        if ViewModel.isValidEmail(input) || ViewModel.isValidPhone(input) {
//            isValidInput = true
//        } else {
//            isValidInput = false
//        }
    }
}

#Preview {
    RegisterView()
}
