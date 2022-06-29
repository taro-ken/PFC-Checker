//
//  PFCcomponentModel.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/06/02.
//

import Foundation
import RealmSwift

final class PFCcomponentModel: Object {
    @objc dynamic var name: String?
    @objc dynamic var protein: Double = 0
    @objc dynamic var fat: Double = 0
    @objc dynamic var carb: Double = 0
    @objc dynamic var calorie: Double = 0
    @objc dynamic var unit: String = ""
    @objc dynamic var unitValue: Int = 0
    @objc dynamic var countValue: Double = 1
    @objc dynamic var flag: Bool = true
    @objc dynamic var totalProtein: Double = 0
    @objc dynamic var totalFat: Double = 0
    @objc dynamic var totalCarb: Double = 0
    @objc dynamic var totalCal: Double = 0
}

