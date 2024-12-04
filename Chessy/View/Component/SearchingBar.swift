//
//  SearchingBar.swift
//  Chessy
//
//  Created by Nguyễn Thành on 04/12/2024.
//

import SwiftUI

struct SearchingBar: View {
    @State private var searchText: String = ""
    @ObservedObject var viewModel = HomeViewViewModel()
    
    var filteredData: [User?] {
        if searchText.isEmpty {
            return viewModel.dataUser
        } else {
            return viewModel.dataUser.filter { user in
                guard let user = user else { return false }
                return user.name.lowercased().contains(searchText.lowercased())
            }
        }
    }

    
    @State private var isShowFiltered: Bool = false
    
    var body: some View {
        VStack {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onTapGesture {
                        isShowFiltered = true
                    }
                
                Spacer()
                
                if !searchText.isEmpty {
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            searchText = ""
                        }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.top, 40)
            
            if !searchText.isEmpty && isShowFiltered && !filteredData.isEmpty {
                // Search Results
                List(filteredData.indices, id: \.self) { id in
                    SearchUserItem(user: filteredData[id]!)
                }
            }
            
            Spacer()
        }
        .onTapGesture {
            isShowFiltered = false
        }
    }
}

#Preview {
    SearchingBar()
}
