//
//  Country.swift
//  Chessy
//
//  Created by Nguyễn Thành on 27/11/2024.
//

import Foundation

struct Country: Codable, Hashable {
    let name: Name
    let flags: Flag
    
    struct Name: Codable, Hashable {
        let common: String
    }
    
    struct Flag: Codable, Hashable {
        let png: String
    }
}
