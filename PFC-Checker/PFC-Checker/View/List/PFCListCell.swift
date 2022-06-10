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
   
    @IBOutlet weak var flagSwich: UISwitch!
    var countvalue:Int = Int()
    private var swichFlag: Bool = true
    var catchCountDelegate: CatchCountProtcol?
    var catchFlagDelegate: CatchFlagProtcol?
    

    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        flagSwich.addTarget(self, action: #selector(swichFlag(_:)), for: .touchUpInside)
      //  countStepper.value = Double(countvalue)
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
    
    func configure(model: PFCcomponentModel) {
       // countvalue = model.unitValue
        PFCname.text = model.name
        proteinValue.text = "P\(model.protein)g"
        fatValue.text = "F\(model.fat)g"
        carbValue.text = "C\(model.carb)g"
        calorieValue.text = "\(model.calorie)Kcal"
        unitValue.text = "\(model.unitValue)\(model.unit)"
        flagSwich.isOn = model.flag
    }
}

protocol CatchCountProtcol {
    func catchCount(row: Int,value: Int,flag: Bool)
}

protocol CatchFlagProtcol {
    func CatchFlag(row: Int,flag: Bool)
}
