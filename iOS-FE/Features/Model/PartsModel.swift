//
//  PartsModel.swift
//  iOS-FE
//
//  Created by wj on 9/29/25.
//

import Foundation

struct Parts: Codable, Identifiable {
    let id: Int
    let name: String
    let quantity: Int
}
