//
//  ProfileViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 15/06/2024.
//

import Foundation
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var userID: String
    @Published var user: User?
    @Published var isLoading: Bool
    @Published var isLoadingHistory: Bool
    @Published var errorMessage: String?
    @Published var matchHistoryList: [MatchHistoryModel?]
    @Published var friendsCount: Int?
    
    init() {
        self.userID = Auth.auth().currentUser!.uid
        self.user = nil
        self.isLoading = true
        self.isLoadingHistory = true
        self.errorMessage = nil
        self.matchHistoryList = []

        User.countFriends(userID: userID) { count in
            DispatchQueue.main.async {
                self.friendsCount = count
            }
        }
    }
    
    func fetchUser() {
        User.getUserByID(userID: userID) { [weak self] user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                if let user = user {
                    self.user = user
                } else {
                    self.errorMessage = "Failed to load user."
                }
            }
        }
    }
    
    func fetchMatchHistory() {
        isLoadingHistory = true
        errorMessage = nil
        
        let timeout = DispatchTime.now() + 10 // 3 giây
        DispatchQueue.main.asyncAfter(deadline: timeout) { [weak self] in
            guard let self = self else { return }
            if self.isLoadingHistory {
                self.isLoadingHistory = false
                self.errorMessage = "Timeout loading match history."
            }
        }
        
        MatchHistoryModel.getAllMatchHistoryByID(playerID: userID) { [weak self] list in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if list.isEmpty {
                    self.errorMessage = "No match history available."
                } else {
                    self.matchHistoryList = list
                }
                self.isLoadingHistory = false
            }
        }
    }
    
    func saveUser(userID: String, user: User) {
        self.isLoading = true
        User.insertUser(userID: userID, user: user)
        DispatchQueue.main.async {
            self.isLoading = false
            self.user = user
            self.errorMessage = nil
        }
    }
    
    func winrate(playerID: String) -> String {
        guard !matchHistoryList.isEmpty else {
            return "--"
        }
        
        // Đếm số trận thắng của người chơi
        let wins = matchHistoryList.filter { $0!.winnerID == playerID }.count
        
        // Tổng số trận đã chơi
        let totalGames = matchHistoryList.count
        
        // Tính winrate (phần trăm)
        let winRate = (Double(wins) / Double(totalGames)) * 100
        
        return String(format: "%.2f%%", winRate)
    }
    
    func winstreak(playerID: String) -> Int {
        guard !matchHistoryList.isEmpty else {
            return 0
        }
        
        var streak = 0
        let historyList = matchHistoryList.compactMap { $0 }.sorted {
            $0.timestamp > $1.timestamp
        }
        for match in historyList {
            if match.winnerID == playerID {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
    
    func getPeakStreak(playerID: String, currentPeak: Int) -> Int {
        guard !matchHistoryList.isEmpty else {
            return 0
        }
        
        let historyList = matchHistoryList.compactMap { $0 }.sorted {
            $0.timestamp > $1.timestamp
        }
        
        var currentStreak = 0
        var maxStreak = 0
        
        for match in historyList {
            if match.winnerID == playerID {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0 // Reset streak nếu thua
            }
        }
        
        if maxStreak > currentPeak {
            // update user peak
            User.updatePeak(userID: playerID, newPeak: maxStreak)
        }
        
        return maxStreak
    }
    
    func getFilteredHistoryList(sortBy: String) -> [MatchHistoryModel?] {
        let validHistoryList = matchHistoryList.compactMap { $0 }.sorted {
            $0.timestamp > $1.timestamp
        }
        
        switch sortBy {
        case "Rank":
            return validHistoryList.filter { $0.type == "Rank" }
        case "Normal":
            return validHistoryList.filter { $0.type == "Normal" }
        default:
            return validHistoryList // Trả về toàn bộ nếu là "All"
        }
    }
}
