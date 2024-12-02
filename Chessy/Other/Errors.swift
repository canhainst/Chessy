//
//  Errors.swift
//  Chessy
//
//  Created by Nguyễn Thành on 02/12/2024.
//

import Foundation

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

enum ImgurError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case invalidImageData
}
