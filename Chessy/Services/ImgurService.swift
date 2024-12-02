//
//  ImgurService.swift
//  Chessy
//
//  Created by Nguyễn Thành on 02/12/2024.
//

import Foundation
import UIKit

class ImgurService: ObservableObject {
    private let clientID = "e032b3bc1ef9e32"
    
    func upload(image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() else {
            throw ImgurError.invalidData
        }
        
        guard let url = URL(string: "https://api.imgur.com/3/image") else {
            throw ImgurError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Client-ID \(clientID)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = ["image": imageData]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, response) = try await URLSession.shared.data(for: request)
                
        // Kiểm tra phản hồi HTTP
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("HTTP Response: \(response)")
            throw ImgurError.invalidResponse
        }
        
        // Giải mã dữ liệu phản hồi
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let link = (json?["data"] as? [String: Any])?["link"] as? String {
                return link
            } else {
                throw ImgurError.invalidData
            }
        } catch {
            throw ImgurError.invalidData
        }
    }
}

struct ImgurResponse: Codable {
    let data: ImgurData
    let success: Bool
    let status: Int
}

struct ImgurData: Codable {
    let id: String
    let title: String?
    let description: String?
    let datetime: Int
    let type: String
    let link: String
}
