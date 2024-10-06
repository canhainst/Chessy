//
//  LoginView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 04/06/2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject var ViewModel = LoginViewViewModel()
    @State private var isSecure: Bool = true
    @State private var emailOrPhone = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HeaderLoginView(Tittle: "Chessy",
                                Subtittle: "Zi chuyển khếu lếu",
                                angle: 10,
                                keyboardHeight: keyboardHeight,
                                BackgroundColor: Color.pink)
                
                // Log in form
                VStack(spacing: 20) {
                    Text("Welcome Back!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    TextField("Email or Number Phone", text: $ViewModel.emailOrPhone)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                    
                    if isSecure {
                        SecureField("Password", text: $ViewModel.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding(.horizontal, 30)
                    } else {
                        TextField("Password", text: $ViewModel.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding(.horizontal, 30)
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            isSecure.toggle()
                        }) {
                            Text(isSecure ? "Show" : "Hide")
                                .font(.caption)
                                .foregroundColor(colorScheme == .light ? .blue : .white)
                        }
                        .padding(.trailing, 40)
                    }
                }
                .offset(y: -30)
                
                if !ViewModel.errorMessage.isEmpty {
                    Text(ViewModel.errorMessage)
                        .foregroundColor(colorScheme == .light ? .blue : .white)
                        .lineLimit(nil)
                }
                
                Button {
                    // Attempt log in
                    ViewModel.login()
                } label: {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                // Create Account
                VStack {
                    Text("Do not have an account?")
                    NavigationLink("Create an account", destination: RegisterView())
                }
                .padding(.bottom, 50)
                
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
        }
    }
}

#Preview {
    LoginView()
}
