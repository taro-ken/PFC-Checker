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
    
    static func menBMRCalculation(age: Double, tool: Double, weight: Double) -> Double {
        let a: Double = 13.397
        let b: Double = 4.799
        let c: Double = 5.677
        let d: Double = 88.362
        let menBMR = ((a * weight) + (b * tool) - (c * age)) + d
        let cutMenBMR = round(menBMR)
        return cutMenBMR
    }
    
    static func womanBMRCalculation(age: Double, tool: Double, weight: Double) -> Double {
        let a: Double = 9.247
        let b: Double = 3.098
        let c: Double = 4.33
        let d: Double = 447.593
        let womanBMR = ((a * weight) + (b * tool) - (c * age)) + d
        let cutWomanBMR = round(womanBMR)
        return cutWomanBMR
    }
    
    static func lowCalculation(value: String) -> Double {
        let low: Double = 1.2
        guard let value = Double(value) else {
            return 0
        }
        if value.isNaN == true {
            return 0
        }
        
        let totalBMR =  value * low
        let cutTotalBMR = round(totalBMR)
        return cutTotalBMR
    }
    
    static func middleCalculation(value: String) -> Double {
        let middle: Double = 1.375
        guard let value = Double(value) else {
            return Double()
        }
        let totalBMR =  value * middle
        let cutTotalBMR = round(totalBMR)
        return cutTotalBMR
    }
    
    static func highCalculation(value: String) -> Double {
        let high: Double = 1.55
        guard let value = Double(value) else {
            return Double()
        }
        let totalBMR =  value * high
        let cutTotalBMR = round(totalBMR)
        return cutTotalBMR
    }
    
    static func superHighCalculation(value: String) -> Double {
        let superHigh: Double = 1.725
        guard let value = Double(value) else {
            return Double()
        }
        let totalBMR =  value * superHigh
        let cutTotalBMR = round(totalBMR)
        return cutTotalBMR
    }
}
