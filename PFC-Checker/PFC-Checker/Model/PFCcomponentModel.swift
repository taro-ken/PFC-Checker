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
    @objc dynamic var protein: Int = 0
    @objc dynamic var fat: Int = 0
    @objc dynamic var carb: Int = 0
    @objc dynamic var calorie: Int = 0
    @objc dynamic var unit: String = ""
    @objc dynamic var unitValue: Int = 0
    @objc dynamic var flag: Bool = true
}

