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
    @IBOutlet weak var countStepper: UIStepper!
    @IBOutlet weak var flagSwich: UISwitch!
    var countvalue:Int = Int()
    private var swichFlag: Bool = true
    var catchCountDelegate: CatchCountProtcol?
    var catchFlagDelegate: CatchFlagProtcol?
    

    @IBOutlet weak var mainBackground: UIView!
    @IBOutlet weak var shadowLayer: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        flagSwich.addTarget(self, action: #selector(swichFlag(_:)), for: .touchUpInside)
        countStepper.addTarget(self, action: #selector(tapStepper(_:)), for: .touchUpInside)
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
    
    @objc func tapStepper(_ sender: UIStepper) {
        let row = sender.tag
        let value = Int(sender.value)
        self.catchCountDelegate?.catchCount(row: row, value: value)
    }
    
    
    
    
    func configure(model: PFCcomponentModel) {
        self.mainBackground.layer.cornerRadius = 8
        self.mainBackground.layer.masksToBounds = true
        PFCname.text = model.name
        proteinValue.text = "P/ \(model.protein)g"
        fatValue.text = "F/ \(model.fat)g"
        carbValue.text = "C/ \(model.carb)g"
        calorieValue.text = "\(model.calorie)kcal"
        unitValue.text = "\(model.unitValue)\(model.unit)"
        flagSwich.isOn = model.flag
        countStepper.value = Double(model.unitValue)
    }
}

protocol CatchCountProtcol {
    func catchCount(row: Int,value: Int)
}

protocol CatchFlagProtcol {
    func CatchFlag(row: Int,flag: Bool)
}


class ShadowView: UIView {
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }

    private func setupShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
