//
//  calculation.swift
//  PFC-Checker
//
//  Created by 木元健太郎 on 2022/06/11.
//

import Foundation

final class calculation {
    static func calculation(totalPFC: Int,totalCal: Int) -> Int {
        let value: Double =  Double(totalPFC) / Double(totalCal)
        let percentValue:Double = value * 100
        if percentValue.isNaN == true {
            return 0
        }
        let valueCutInt = Int(round(percentValue))
        return valueCutInt
    }
}
