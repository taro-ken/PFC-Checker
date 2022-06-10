//
//  UITextField+.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/06/03.
//

import UIKit

extension UITextField {
    var textToInt: Int {
        let text = self.text
        let int = text
            .flatMap{Int($0)} ?? 0
        return int
    }
}
