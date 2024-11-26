//
//  CountryViewModel.swift
//  Chessy
//
//  Created by Nguyễn Thành on 27/11/2024.
//

import Foundation

class CountryViewModel: ObservableObject {
    func fetchCountries() async throws -> [Country] {
        guard let url = URL(string: "https://restcountries.com/v3.1/all") else {
            throw GHError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([Country].self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
