//
//  GameplayView.swift
//  Chessy
//
//  Created by Nguyễn Thành on 05/10/2024.
//

import SwiftUI

struct GameplayView: View {
    @ObservedObject var viewModel = ChessGameViewModel()
    
    @State private var avatar = "https://scontent.fsgn5-14.fna.fbcdn.net/v/t39.30808-6/329403231_474295524745893_3398994404525045455_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=6ee11a&_nc_ohc=a2CuVbMC_7sQ7kNvgF1OdR8&_nc_ht=scontent.fsgn5-14.fna&_nc_gid=Aj_52EeNMyhMviAl6CaI-Ob&oh=00_AYDRSPuFYsO-3jbvdVzrQZvgba2QD_I1GA56n0AQOlbnHA&oe=67051EAD"
    
    @State private var avatarE = "https://scontent.fsgn5-9.fna.fbcdn.net/v/t39.30808-1/358969835_1295627944715660_3629977290591665492_n.jpg?stp=dst-jpg_s480x480&_nc_cat=102&ccb=1-7&_nc_sid=0ecb9b&_nc_ohc=gtW1Gt2_1cEQ7kNvgEnDCQP&_nc_ht=scontent.fsgn5-9.fna&_nc_gid=Az0sZmRT_Wh3QXNYMd7ySUv&oh=00_AYDJX-tKbFz6FsfAR6mlomKEKlcLMRU44mNnYEVj-cM5yQ&oe=67064B0C"
    
    @State private var player = "CanhaiNST"
    @State private var playerE = "Tokumei Shisa"
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Image(systemName: "arrow.left")
                    .font(.title)
                
                Spacer()
                
                Text("Room Code: B31686")
            }
            .padding()
            
            HStack{
                HStack (alignment: .top) {
                    AsyncImage(url: URL(string: avatar)) { phase in
                        switch phase {
                        case .empty:
                            // Placeholder while loading
                            BlankAvatarView(width: 50, height: 50)
                        case .success(let image):
                            // Successfully loaded image
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        case .failure:
                            // Failure loading image
                            BlankAvatarView(width: 50, height: 50)
                        @unknown default:
                            BlankAvatarView(width: 50, height: 50)
                        }
                    }
                    VStack (alignment: .leading, spacing: 0) {
                        Text(player)
                        Image("VN")
                            .resizable()
                            .aspectRatio(contentMode: .fit) // Giữ tỷ lệ ảnh
                            .frame(width: 30)
                    }
                }
                .padding()
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0.5)
                
                Spacer()
            }
            .padding() // Khoảng đệm xung quanh
            
            Text("Black's turn")
                .font(.headline) // Đặt kiểu chữ
                .padding() // Thêm khoảng cách xung quanh văn bản
                .foregroundColor(viewModel.whiteTurn ? .clear : .black)
            
            ChessBoardView(viewModel: viewModel)
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0.5)
            
            
            Text("White's turn")
                .font(.headline) // Đặt kiểu chữ
                .padding() // Thêm khoảng cách xung quanh văn bản
                .foregroundColor(viewModel.whiteTurn ? .black : .clear)
            
            HStack {
                Spacer()
                
                HStack (alignment: .top) {
                    VStack (alignment: .trailing, spacing: 0) {
                        Text(playerE)
                        Image("VN")
                            .resizable()
                            .aspectRatio(contentMode: .fit) // Giữ tỷ lệ ảnh
                            .frame(width: 30)
                    }
                    AsyncImage(url: URL(string: avatarE)) { phase in
                        switch phase {
                        case .empty:
                            // Placeholder while loading
                            BlankAvatarView(width: 50, height: 50)
                        case .success(let image):
                            // Successfully loaded image
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        case .failure:
                            // Failure loading image
                            BlankAvatarView(width: 50, height: 50)
                        @unknown default:
                            BlankAvatarView(width: 50, height: 50)
                        }
                    }
                }
                .padding()
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 0.5)
            }
            .padding() // Khoảng đệm xung quanh
        }
    }
}

#Preview {
    GameplayView()
}
