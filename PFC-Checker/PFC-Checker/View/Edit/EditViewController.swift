//
//  EditViewController.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/06/06.
//

import UIKit
import RealmSwift
import RxSwift

final class EditViewController: UIViewController {
    
    
@IBOutlet weak var editInfoNameLabel: UITextField!
@IBOutlet weak var editProteinValueLabel: UITextField!
@IBOutlet weak var editFatValuelabel: UITextField!
@IBOutlet weak var editCarbValueLabel: UITextField!
@IBOutlet weak var editCalorieValueLabel: UITextField!
@IBOutlet weak var editUnitLabel: UITextField!
@IBOutlet weak var editUnitValueLabel: UITextField!
@IBOutlet weak var countStepper: UIStepper!
@IBOutlet weak var flagSwich: UISwitch!
    
    @IBOutlet weak var topBar: UINavigationBar!
    
    private let viewModel = PFCViewModel()
    private lazy var input: PFCViewModelInput = viewModel
    private lazy var output: PFCViewModelOutput = viewModel
    private let disposeBug = DisposeBag()

    private let realm = try! Realm()
    var row:Int = Int()
    var swichFlag:Bool = Bool()

    override func viewDidLoad() {
        super.viewDidLoad()
        topBar.barTintColor = .white
        let data = realm.objects(PFCcomponentModel.self)
        editInfoNameLabel.text = data[row].name
        editProteinValueLabel.text = data[row].protein.description
        editFatValuelabel.text = data[row].fat.description
        editCarbValueLabel.text = data[row].carb.description
        editCalorieValueLabel.text = data[row].calorie.description
        editUnitLabel.text = data[row].unit
        editUnitValueLabel.text = data[row].unitValue.description
        swichFlag = data[row].flag
        countStepper.value = Double(data[row].unitValue)
        
        if swichFlag == true {
            flagSwich.isOn = true
        } else {
            flagSwich.isOn = false
        }
        
    }
    
    @IBAction func tappedCount(_ sender: UIStepper) {
        let count = Int(sender.value)
        editUnitValueLabel.text = count.description
    }
    
    
    @IBAction func tappedSwich(_ sender: UISwitch) {
        let isOn = sender.isOn
        if isOn == true {
            swichFlag = true
        } else {
            swichFlag = false
        }
    }
    
    @IBAction func tappedEdit(_ sender: Any) {
        input.editInfo(name: editInfoNameLabel.text, protein: editProteinValueLabel.textToInt, fat: editFatValuelabel.textToInt, carb: editCarbValueLabel.textToInt, calorie: editCalorieValueLabel.textToInt, unit: editUnitLabel.text, unitValue: editUnitValueLabel.textToInt, flag: swichFlag, row: row)
        self.dismiss(animated: true)
    }
    
    @IBAction func tappedCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    
}
