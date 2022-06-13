//
//  EditViewController.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/06/06.
//

import UIKit
import RealmSwift
import RxSwift
import Eureka

final class EditViewController: FormViewController {
    
    private let viewModel = PFCViewModel()
    private lazy var input: PFCViewModelInput = viewModel
    private lazy var output: PFCViewModelOutput = viewModel
    private let disposeBug = DisposeBag()

    private let realm = try! Realm()
    var row:Int = Int()
    var swichFlag:Bool = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        formSetUp()
    }
    
    @IBAction func tappedEditButton(_ sender: Any) {
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
              let unitValueRow = (self.form.rowBy(tag: EurekaTagString.settingUnitValue) as! StepperRow).value,
              let swichRow = (self.form.rowBy(tag: EurekaTagString.settingSwich) as! SwitchRow).value
        else {
            return
        }
        input.editInfo(name: nameRow, protein: Int(pRow), fat: Int(fRow), carb: Int(cRow), calorie: Int(calRow), unit: unitRow, unitValue: Int(unitValueRow), flag: swichRow, row: row)
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension EditViewController {
    private func formSetUp() {
        let data = realm.objects(PFCcomponentModel.self)
        form +++ Section()
        <<< TextRow(EurekaTagString.settingName){
            $0.title = EurekaTagString.settingName
            $0.placeholder = "登録名を入力"
            $0.tag = EurekaTagString.settingName
            $0.add(rule: RuleRequired())
            $0.validationOptions = .validatesOnChange
            $0.value = data[row].name
            
        }.cellUpdate { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
        }
        
        form +++ Section()
        <<< TextRow(EurekaTagString.settingUnit){
            $0.title = EurekaTagString.settingUnit
            $0.placeholder = "例 100g,1個,1パック"
            $0.tag = EurekaTagString.settingUnit
            $0.add(rule: RuleRequired())
            $0.validationOptions = .validatesOnChange
            $0.value = data[row].unit
            
        }.cellUpdate { cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
        }
        
       form +++ Section()
        <<< DecimalRow (EurekaTagString.settingP){
            $0.title = EurekaTagString.settingP
            $0.placeholder = "量を入力"
            $0.tag = EurekaTagString.settingP
            $0.value = Double(data[row].protein)
            
            $0.useFormatterDuringInput = true
            let formatter = DecimalFormatter()
            formatter.locale = .current
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            $0.formatter = formatter
        }.cellUpdate { [self] cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
            
            input.pValue.accept(cell.row.value)
            input.calorieSet()
        }
        
        <<< DecimalRow(EurekaTagString.settingF){
            $0.title = EurekaTagString.settingF
            $0.placeholder = "量を入力"
            $0.tag = EurekaTagString.settingF
            $0.value = Double(data[row].fat)
            $0.useFormatterDuringInput = true
            let formatter = DecimalFormatter()
            formatter.locale = .current
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            $0.formatter = formatter
        }.cellUpdate { [self] cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
            input.fValue.accept(cell.row.value)
            input.calorieSet()
        }
        
        <<< DecimalRow(EurekaTagString.settingC){
            $0.title = EurekaTagString.settingC
            $0.placeholder = "量を入力"
            $0.tag = EurekaTagString.settingC
            $0.value = Double(data[row].carb)
            $0.useFormatterDuringInput = true
            let formatter = DecimalFormatter()
            formatter.locale = .current
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            $0.formatter = formatter
        }.cellUpdate { [self] cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
            input.cValue.accept(cell.row.value)
            input.calorieSet()
        }
        
        <<< DecimalRow(EurekaTagString.settingCal){
            $0.title = EurekaTagString.settingCal
            $0.placeholder = "タップして取得"
            $0.tag = EurekaTagString.settingCal
            $0.value = Double(data[row].calorie)
            $0.useFormatterDuringInput = true
            let formatter = DecimalFormatter()
            formatter.locale = .current
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            $0.formatter = formatter
        }.cellUpdate { [self] cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
            }
            input.calValue.asDriver().drive { value in
                row.value = value
            }.disposed(by: disposeBug)
            input.calorieSet()
        }
        
        form +++ Section()
        <<< StepperRow(EurekaTagString.settingUnitValue) {
            $0.title = "数量"
            $0.tag = EurekaTagString.settingUnitValue
            $0.value = Double(data[row].unitValue)
        }.cellSetup({ [self] (cell, rows) in
            rows.value = Double(data[row].unitValue)
            cell.valueLabel.text = "\(Int(rows.value!))"
        }).cellUpdate({ (cell, row) in
            if(row.value != nil)
            {
                cell.valueLabel.text = "\(Int(row.value!))"
            }
        }).onChange({ (row) in
            if(row.value != nil)
            {
                row.cell.valueLabel.text = "\(Int(row.value!))"
            }
        })
        +++ Section()
        <<< SwitchRow(){
            $0.tag = EurekaTagString.settingSwich
            $0.title = "追加/未追加"
            $0.value = data[row].flag
        }.onChange{[weak self] row in
            self?.swichFlag = row.value!
        }
    }
}


