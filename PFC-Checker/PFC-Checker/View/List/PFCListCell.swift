//
//  PFCListCell.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/06/03.
//

import UIKit

final class PFCListCell: UITableViewCell {
    
    @IBOutlet weak var PFCname: UILabel!
    @IBOutlet weak var proteinValue: UILabel!
    @IBOutlet weak var fatValue: UILabel!
    @IBOutlet weak var carbValue: UILabel!
    @IBOutlet weak var calorieValue: UILabel!
    @IBOutlet weak var unitValue: UILabel!
   
    @IBOutlet weak var countChange: UIButton!
    @IBOutlet weak var flagSwich: UISwitch!
    @IBOutlet weak var mainBackground: UIView!
    @IBOutlet weak var shadowLayer: UIView!
    
    private var swichFlag: Bool = true
     var catchCountDelegate: CatchCountProtcol?
     var catchFlagDelegate: CatchFlagProtcol?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        countChange.titleLabel?.text = nil
        countChange.layer.cornerRadius = 10
        flagSwich.addTarget(self, action: #selector(swichFlag(_:)), for: .touchUpInside)
        countChange.addTarget(self, action: #selector(tapCountChange(_:)), for: .touchUpInside)
        PFCname.font = UIFont(name: "pingfanghk-Medium", size: 20)
        unitValue.font = UIFont(name: "pingfanghk-Medium", size: 15)
    }
    
    @objc func swichFlag(_ sender: UISwitch) {
        let row = sender.tag
        let isOn = sender.isOn
        
        if isOn {
            swichFlag = true
        } else {
            swichFlag = false
        }
        self.catchFlagDelegate?.CatchFlag(row: row, flag: swichFlag)
    }
    
    @objc func tapCountChange(_ sender: UIButton) {
        let row = sender.tag
        self.catchCountDelegate?.catchCount(row: row)
    }

    func configure(model: PFCcomponentModel) {
        self.mainBackground.layer.cornerRadius = 8
        self.mainBackground.layer.masksToBounds = true
        PFCname.text = model.name
        proteinValue.text = "P/ \(calculation.doubleToString(value: model.totalProtein))g"
        fatValue.text = "F/ \(calculation.doubleToString(value: model.totalFat))g"
        carbValue.text = "C/ \(calculation.doubleToString(value: model.totalCarb))g"
        calorieValue.text = "\(calculation.doubleToString(value: model.totalCal))kcal"
        unitValue.text = "\(calculation.doubleToString(value: Double(model.unitValue) * model.countValue)) \(model.unit)"
        flagSwich.isOn = model.flag
        countChange.setTitle("\(calculation.doubleToString(value: model.countValue))", for: .normal)
    }
}

protocol CatchCountProtcol {
    func catchCount(row: Int)
}

protocol CatchFlagProtcol {
    func CatchFlag(row: Int,flag: Bool)
}
