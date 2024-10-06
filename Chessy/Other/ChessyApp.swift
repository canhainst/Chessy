//
//  ChessyApp.swift
//  Chessy
//
//  Created by Nguyễn Thành on 03/06/2024.
//

import FirebaseCore
import SwiftUI

@main
struct ChessyApp: App {
    @StateObject private var mainViewModel = MainViewViewModel()
    
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
