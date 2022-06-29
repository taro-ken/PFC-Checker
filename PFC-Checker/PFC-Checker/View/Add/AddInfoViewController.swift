//
//  AddInfoViewController.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/06/02.
//

import UIKit
import RxSwift
import RxCocoa
import Eureka

final class AddInfoViewController: FormViewController {
    
    private let viewModel: ViewModelType = PFCViewModel()
    private let disposeBug = DisposeBag()
    private var swichFlag:Bool = true
    private var hoge: Double = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formSetUp()
    }
    
    @IBAction func tappedSaveAddButton(_ sender: Any) {
        let errors = self.form.validate()
        guard errors.isEmpty else {
            let alert = UIAlertController(title: "エラー", message: "未入力の箇所があります", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        }
        guard let nameRow = (self.form.rowBy(tag: EurekaTagString.settingName) as! TextRow).value,
              let pRow = (self.form.rowBy(tag: EurekaTagString.settingP) as! DecimalRow).value,
              let fRow = (self.form.rowBy(tag: EurekaTagString.settingF) as! DecimalRow).value,
              let cRow = (self.form.rowBy(tag: EurekaTagString.settingC) as! DecimalRow).value,
              let calRow = (self.form.rowBy(tag: EurekaTagString.settingCal) as! DecimalRow).value,
              let unitRow = (self.form.rowBy(tag: EurekaTagString.settingUnit) as! TextRow).value,
              let unitValueRow = (self.form.rowBy(tag: EurekaTagString.settingUnitValue) as! IntRow).value,
              let swichRow = (self.form.rowBy(tag: EurekaTagString.settingSwich) as! SwitchRow).value
        else {
            return
        }
        viewModel.input.addInfo(name: nameRow, protein: pRow, fat: fRow, carb: cRow, calorie: calRow, unit: unitRow, countValue: 1, unitValue: unitValueRow, flag: swichRow)
        self.navigationController?.popViewController(animated: true)
    }
}

extension AddInfoViewController {
    private func formSetUp() {
        
        form +++ Section()
        <<< TextRow(EurekaTagString.settingName){ row in
            row.title = EurekaTagString.settingName
            row.placeholder = "登録名を入力"
            row.tag = EurekaTagString.settingName
            row.add(rule: RuleRequired())
            row.validationOptions = .validatesOnChange
        }.cellUpdate { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
        }
        
//        form +++ Section()
//        <<< TextRow(EurekaTagString.settingUnit){ row in
//            row.title = EurekaTagString.settingUnit
//            row.placeholder = "例 100g,1個,1パック"
//            row.tag = EurekaTagString.settingUnit
//            row.add(rule: RuleRequired())
//            row.validationOptions = .validatesOnChange
//        }.cellUpdate { cell, row in
//            if !row.isValid {
//                cell.titleLabel?.textColor = .systemRed
//            }
//        }
        
        form +++ Section()
        <<< DecimalRow (EurekaTagString.settingP){ row in
            row.title = EurekaTagString.settingP
            row.placeholder = "値を入力"
            row.tag = EurekaTagString.settingP
            row.add(rule: RuleRequired())
            row.validationOptions = .validatesOnChange
            row.useFormatterOnDidBeginEditing = false
            row.useFormatterDuringInput = false
            let numberFormatter = NumberFormatter()
             numberFormatter.maximumFractionDigits = 1
             numberFormatter.numberStyle = NumberFormatter.Style.decimal
            row.formatter = numberFormatter
        }.cellUpdate { [self] cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
        }
        
        <<< DecimalRow(EurekaTagString.settingF){ row in
            row.title = EurekaTagString.settingF
            row.placeholder = "値を入力"
            row.tag = EurekaTagString.settingF
            row.add(rule: RuleRequired())
            row.validationOptions = .validatesOnChange
            row.useFormatterOnDidBeginEditing = false
            row.useFormatterDuringInput = false
            let numberFormatter = NumberFormatter()
             numberFormatter.maximumFractionDigits = 1
             numberFormatter.numberStyle = NumberFormatter.Style.decimal
            row.formatter = numberFormatter
        }.cellUpdate { [self] cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
        }
        
        <<< DecimalRow(EurekaTagString.settingC){ row in
            row.title = EurekaTagString.settingC
            row.placeholder = "値を入力"
            row.tag = EurekaTagString.settingC
            row.add(rule: RuleRequired())
            row.validationOptions = .validatesOnChange
            row.useFormatterOnDidBeginEditing = false
            row.useFormatterDuringInput = false
            let numberFormatter = NumberFormatter()
             numberFormatter.maximumFractionDigits = 1
             numberFormatter.numberStyle = NumberFormatter.Style.decimal
            row.formatter = numberFormatter
        }.cellUpdate { [self] cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
        }
        
        <<< DecimalRow(EurekaTagString.settingCal){ row in
            row.title = EurekaTagString.settingCal
            row.placeholder = "値を入力"
            row.tag = EurekaTagString.settingCal
            row.add(rule: RuleRequired())
            row.validationOptions = .validatesOnChange
            row.useFormatterOnDidBeginEditing = false
            row.useFormatterDuringInput = false
            let numberFormatter = NumberFormatter()
             numberFormatter.maximumFractionDigits = 1
             numberFormatter.numberStyle = NumberFormatter.Style.decimal
            row.formatter = numberFormatter
        }.cellUpdate { [self] cell, row in
            if !row.isValid  {
                cell.titleLabel?.textColor = .systemRed
            }
        }
        
        form +++ Section()
        <<< IntRow(EurekaTagString.settingUnitValue){ row in
            row.title = EurekaTagString.settingUnitValue
            row.placeholder = "1単位あたりの量"
            row.tag = EurekaTagString.settingUnitValue
            row.add(rule: RuleRequired())
            row.validationOptions = .validatesOnChange
            row.useFormatterOnDidBeginEditing = false
            row.useFormatterDuringInput = false
            let numberFormatter = NumberFormatter()
             numberFormatter.maximumFractionDigits = 1
             numberFormatter.numberStyle = NumberFormatter.Style.decimal
            row.formatter = numberFormatter
        }.cellUpdate { [self] cell, row in
            if !row.isValid  {
                cell.titleLabel?.textColor = .systemRed
            }
        }
        
        <<< TextRow(EurekaTagString.settingUnit){ row in
            row.title = EurekaTagString.settingUnit
            row.placeholder = "例 g,個,パック,缶"
            row.tag = EurekaTagString.settingUnit
            row.add(rule: RuleRequired())
            row.validationOptions = .validatesOnChange
        }.cellUpdate { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
        }
    
        +++ Section()
        <<< SwitchRow(){ row in
            row.tag = EurekaTagString.settingSwich
            row.title = "追加/未追加"
            row.value = true
        }.onChange{[weak self] row in
            self?.swichFlag = row.value!
        }
        
}

}
