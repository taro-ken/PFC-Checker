//
//  AddInfoViewController.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/06/02.
//

import UIKit
import RxSwift
import RxCocoa

final class AddInfoViewController: UIViewController {
    
    @IBOutlet weak var addInfoNameLabel: UITextField!
    @IBOutlet weak var proteinValueLabel: UITextField!
    @IBOutlet weak var fatValuelabel: UITextField!
    @IBOutlet weak var carbValueLabel: UITextField!
    @IBOutlet weak var calorieValueLabel: UITextField!
    @IBOutlet weak var unitLabel: UITextField!
    @IBOutlet weak var unitValueLabel: UITextField!
    @IBOutlet weak var countStepper: UIStepper!
    @IBOutlet weak var flagSwich: UISwitch!
    
    @IBOutlet weak var topBar: UINavigationBar!
    
    
    private let viewModel = PFCViewModel()
    private lazy var input: PFCViewModelInput = viewModel
    private lazy var output: PFCViewModelOutput = viewModel
    private let disposeBug = DisposeBag()
    var swichFlag:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topBar.barTintColor = .white
        unitValueLabel.text = "1"
        bindInputStream()
    }
    
    private func bindInputStream() {
        let p = proteinValueLabel.rx.text.map{ Int($0!) ?? 0 }
        let f = fatValuelabel.rx.text.map{ Int($0!) ?? 0 }
        let c = carbValueLabel.rx.text.map{ Int($0!) ?? 0 }
        
           Observable
               .combineLatest(p,f,c) { ($0 * 4) + ($1 * 9) + ($2 * 4) }
               .map { $0.description }
               .bind(to:calorieValueLabel.rx.text)
               .disposed(by: disposeBug)
    }
    
    @IBAction func tappedCount(_ sender: UIStepper) {
        let count = Int(sender.value)
        unitValueLabel.text = count.description
    }
    
    @IBAction func tappedSwich(_ sender: UISwitch) {
        let isOn = sender.isOn
        if isOn == true {
            swichFlag = true
        } else {
            swichFlag = false
        }
    }
    
    @IBAction func tapSaveButton(_ sender: Any) {
        input.addInfo(name: addInfoNameLabel.text, protein: proteinValueLabel.textToInt, fat: fatValuelabel.textToInt, carb: carbValueLabel.textToInt, calorie: calorieValueLabel.textToInt, unit: unitLabel.text, unitValue: unitValueLabel.textToInt,flag: swichFlag)
        dismiss(animated: true)
    }
    
    @IBAction func tappedCancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    

}
