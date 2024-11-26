//
//  RegisterView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 04/06/2024.
//

import SwiftUI

struct pickAvatarView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    
    var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    ZStack {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    }
                }
            } else {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 150, height: 150)
                            .overlay(Circle().stroke(Color.black, lineWidth: 1))

                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.black)
                    }
                }
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage, isImagePickerPresented: $isImagePickerPresented)
        }
    }
}

struct RegisterView: View {
    @State private var keyboardHeight: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    
    @State private var ageString = ""
    @State private var isSecure: Bool = true
    
    @StateObject var Register = RegisterViewViewModel()
    @StateObject var viewModel = CountryViewModel()
    @State private var country: [Country] = []
    
    var body: some View {
        NavigationView{
            ZStack{
                // Header
                HeaderLoginView(Tittle: "Resgiter",
                                Subtittle: "Let's fight for honor",
                                angle: 10, keyboardHeight: keyboardHeight,
                                BackgroundColor: Color.green)
                
                ScrollView {
                    VStack (spacing: 15) {
                        Spacer()
                        
                        ZStack {
                            pickAvatarView()
                                .offset(y: -5)
                            if let selectedCountry = Register.nation {
                                VStack {
                                    if let flagURL = URL(string: selectedCountry.flags.png) {
                                        AsyncImage(url: flagURL) { image in
                                            image.resizable()
                                                 .scaledToFit()
                                                 .frame(width: 50, height: 30)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                }
                                .padding()
                                .offset(y: 65)
                            }
                        }
                        
                        
                        TextField("Email or Number Phone", text: $Register.emailOrPhone)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        
                        if isSecure {
                            SecureField("Password", text: $Register.password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        } else {
                            TextField("Password", text: $Register.password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
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
                        }
                                            
                        HStack (spacing: 15) {
                            TextField("User name", text: $Register.name)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            
                            Picker("Region", selection: $Register.region) {
                                Text("Asia").tag("Asia")
                                Text("Europe").tag("Europe")
                                Text("Africa").tag("Africa")
                                Text("Australia").tag("Australia")
                                Text("North America").tag("North America")
                                Text("South America").tag("South America")
                                Text("Antarctica").tag("Antarctica")
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                        
                        HStack(spacing: 15) {
                            TextField("Year of birth", text: $ageString)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .keyboardType(.numberPad)
                                .onChange(of: ageString) { newValue in
                                    Register.age = Int(newValue) ?? 0
                                }
                            
                            Picker("Select Country", selection: $Register.nation) {
                                let sortedCountries = country.sorted { $0.name.common < $1.name.common }
                                
                                ForEach(sortedCountries.indices, id: \.self) { index in
                                    Text(sortedCountries[index].name.common).tag(sortedCountries[index] as Country?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                        
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
                    .padding(.horizontal, 30)
                    .frame(width: UIScreen.main.bounds.width)
                }
                .offset(y: 100)
            }
            .task{
                do {
                    country = try await viewModel.fetchCountries()
                } catch GHError.invalidURL {
                    print("Invalid URL")
                } catch GHError.invalidData {
                    print("Invalid Data")
                } catch GHError.invalidResponse {
                    print("Invalid Response")
                } catch {
                    print("Unknow error")
                }
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
