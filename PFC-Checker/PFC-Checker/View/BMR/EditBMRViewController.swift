//
//  EditBMRViewController.swift
//  PFC-Checker
//
//  Created by 木元健太郎 on 2022/06/16.
//

import UIKit
import RxSwift

final class EditBMRViewController: UIViewController {
    
    @IBOutlet weak var editAgeTextField: UITextField!
    @IBOutlet weak var editToolTextField: UITextField!
    @IBOutlet weak var editWeightTextField: UITextField!
    @IBOutlet weak var editBMRLabel: UILabel!
    @IBOutlet weak var editTotalBMRLabel: UILabel!
    
    @IBOutlet weak var editSexState: UISegmentedControl!
    @IBOutlet weak var editActiveState: UISegmentedControl!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editCalculationButton: UIButton!
    
    private let viewModel = PFCViewModel()
    
    private lazy var input: PFCViewModelInput = viewModel
    private lazy var output: PFCViewModelOutput = viewModel
    private let disposeBug = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        FetchData()
        setup()
    }
    
    @IBAction func tappedAddButton(_ sender: Any) {
        if editAgeTextField.text!.count == 0
            || editToolTextField.text!.count == 0
            || editWeightTextField.text!.count == 0 {
            let alert = UIAlertController(title: "エラー", message: "未入力の箇所があります", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return
        } else {
            guard let total = editTotalBMRLabel.text else {
                return
            }
            let dataModel = BMRModel.init(sex: editSexState.selectedSegmentIndex, age: editAgeTextField.text, tool: editToolTextField.text, weight: editWeightTextField.text, active: editActiveState.selectedSegmentIndex, bmr: editBMRLabel.text, total: total)
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
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
        input.bmrCalculation(sex: editSexState.selectedSegmentIndex, age: editAgeTextField.text, tool: editToolTextField.text, weight: editWeightTextField.text, active: editActiveState.selectedSegmentIndex)
    }
    
    private func bind() {
        output.bmrValue.bind(to: editBMRLabel.rx.text).disposed(by: disposeBug)
        output.totalBMRValue.bind(to: editTotalBMRLabel.rx.text).disposed(by: disposeBug)
    }
}

extension EditBMRViewController {
    private func setup() {
        editButton.layer.cornerRadius = 10
        editButton.layer.shadowOpacity = 1
        editButton.layer.shadowRadius = 2
        editButton.layer.shadowColor = UIColor.gray.cgColor
        editButton.layer.shadowOffset = CGSize(width: 2, height: 1)
        
        editCalculationButton.layer.cornerRadius = 10
        editCalculationButton.layer.shadowOpacity = 1
        editCalculationButton.layer.shadowRadius = 2
        editCalculationButton.layer.shadowColor = UIColor.gray.cgColor
        editCalculationButton.layer.shadowOffset = CGSize(width: 2, height: 1)
        
        editAgeTextField.keyboardType = .decimalPad
        editToolTextField.keyboardType = .decimalPad
        editWeightTextField.keyboardType = .decimalPad
    }
    
    private func FetchData() {
        let jsonDecoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: "a"),
              let dataModel = try? jsonDecoder.decode(BMRModel.self, from: data),
              let sex = dataModel.sex,
              let active = dataModel.active else {
            return
        }
        editSexState.selectedSegmentIndex = sex
        editAgeTextField.text = dataModel.age
        editToolTextField.text = dataModel.tool
        editWeightTextField.text = dataModel.weight
        editActiveState.selectedSegmentIndex = active
        editBMRLabel.text = dataModel.bmr
        editTotalBMRLabel.text = dataModel.total
    }
}

