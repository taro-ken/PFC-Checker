//
//  BMRViewController.swift
//  PFC-Checker
//
//  Created by 木元健太郎 on 2022/06/10.
//

import UIKit
import RxSwift

final class BMRViewController: UIViewController {
    
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var toolTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var bmrLabel: UILabel!
    @IBOutlet weak var totalBMRLabel: UILabel!
    @IBOutlet weak var sexState: UISegmentedControl!
    @IBOutlet weak var activeState: UISegmentedControl!
    
    @IBOutlet weak var calculationButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    private let viewModel = PFCViewModel()
    private lazy var input: PFCViewModelInput = viewModel
    private lazy var output: PFCViewModelOutput = viewModel
    private let disposeBug = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setup()
    }
    
    @IBAction func tappedAddButton(_ sender: Any) {
        if ageTextField.text!.count == 0
            || toolTextField.text!.count == 0
            || weightTextField.text!.count == 0 {
            let alert = UIAlertController(title: "エラー", message: "未入力の箇所があります", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        } else {
            guard let total = totalBMRLabel.text else {
                return
            }
            let dataModel = BMRModel.init(sex: sexState.selectedSegmentIndex, age: ageTextField.text, tool: toolTextField.text, weight: weightTextField.text, active: activeState.selectedSegmentIndex, bmr: bmrLabel.text, total: total)
            
            let jsonEncoder = JSONEncoder()
            guard let data = try? jsonEncoder.encode(dataModel) else {
                return
            }
            UserDefaults.standard.set(data, forKey: "a")
            let alert = UIAlertController(title: nil, message: "登録が完了しました", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func tappedCalculationButton(_ sender: Any) {
        input.bmrCalculation(sex: sexState.selectedSegmentIndex, age: ageTextField.text, tool: toolTextField.text, weight: weightTextField.text, active: activeState.selectedSegmentIndex)
    }
    
    private func bind() {
        output.bmrValue.bind(to: bmrLabel.rx.text).disposed(by: disposeBug)
        output.totalBMRValue.bind(to: totalBMRLabel.rx.text).disposed(by: disposeBug)
    }
}

extension BMRViewController {
    private func setup() {
        saveButton.layer.cornerRadius = 10
        saveButton.layer.shadowOpacity = 1
        saveButton.layer.shadowRadius = 2
        saveButton.layer.shadowColor = UIColor.gray.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 2, height: 1)
        
        calculationButton.layer.cornerRadius = 10
        calculationButton.layer.shadowOpacity = 1
        calculationButton.layer.shadowRadius = 2
        calculationButton.layer.shadowColor = UIColor.gray.cgColor
        calculationButton.layer.shadowOffset = CGSize(width: 2, height: 1)
        
        ageTextField.keyboardType = .decimalPad
        toolTextField.keyboardType = .decimalPad
        weightTextField.keyboardType = .decimalPad
    }
}
