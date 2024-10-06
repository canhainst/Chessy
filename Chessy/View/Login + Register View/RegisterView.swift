//
//  RegisterView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 04/06/2024.
//

import SwiftUI

struct RegisterView: View {
    @State private var keyboardHeight: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    
    @State private var ageString = ""
    @State private var isSecure: Bool = true
    
    @StateObject var Register = RegisterViewViewModel()
    
    var body: some View {
        NavigationView{
            VStack{
                // Header
                HeaderLoginView(Tittle: "Resgiter",
                                Subtittle: "Let's fight for honor",
                                angle: 10, keyboardHeight: keyboardHeight,
                                BackgroundColor: Color.green)
    
                VStack {
                    TextField("Email or Number Phone", text: $Register.emailOrPhone)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal, 30)

                    if isSecure {
                        SecureField("Password", text: $Register.password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding(.horizontal, 30)
                    } else {
                        TextField("Password", text: $Register.password)
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
                    
                    TextField("User name", text: $Register.name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal, 30)
                    
                    HStack(spacing: 20) {
                        Text("Year of Birth")
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        TextField("2000", text: $ageString)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding(.horizontal, 10)
                            .keyboardType(.numberPad)
                            .onChange(of: ageString) { newValue in
                                Register.age = Int(newValue) ?? 0
                            }
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 20) {
                        Text("Region")
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                        Picker("Region", selection: $Register.region) {
                            Text("Asia").tag("Asia")
                            Text("Europe").tag("Europe")
                            Text("Africa").tag("Africa")
                            Text("Australia").tag("Australia")
                            Text("North America").tag("North America")
                            Text("South America").tag("South America")
                            Text("Antarctica").tag("Antarctica")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal, 10)
                    }
                    .padding(.horizontal, 20)
                    
                    Text(Register.errorMessage)
                        .foregroundColor(colorScheme == .light ? .blue : .white)
                        .padding()
                            
                    Button(action: {
                        Register.region = (Register.region == "" ? "Asia" : Register.region)
                        Register.register()
                    }) {
                        Text(Register.isValidInput ? Register.buttonLabel : "Confirm")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 200, height: 50)
                            .background(Register.isValidInput ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!Register.isValidInput)
                    .padding()
                }
                .offset(y: -30)
                
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
    RegisterView()
}
