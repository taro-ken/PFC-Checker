//
//  BMRModel.swift
//  PFC-Checker
//
//  Created by 木元健太郎 on 2022/06/14.
//

import Foundation

struct BMRModel: Codable {
    var sex: Int?
    var age: String?
    var tool: String?
    var weight: String?
    var active: Int?
    var bmr: String?
    var total: String
}
