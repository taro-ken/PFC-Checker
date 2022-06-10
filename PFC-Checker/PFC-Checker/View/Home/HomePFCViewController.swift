//
//  HomePFCViewController.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/05/31.
//

import UIKit
import Charts
import RxSwift


final class HomePFCViewController: UIViewController {
    
    @IBOutlet weak var mainTopVew: UIView!
    @IBOutlet weak var totalCalView: UIView!
    @IBOutlet weak var diffCalLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var pfcStac: UIStackView!
    @IBOutlet weak var proteinBackView: UIView!
    @IBOutlet weak var fatBackView: UIView!
    @IBOutlet weak var carbBackView: UIView!
    @IBOutlet weak var proteinLabelView: UIView!
    @IBOutlet weak var fatLabelView: UIView!
    @IBOutlet weak var carbLabelView: UIView!
    @IBOutlet weak var totalCalLabel: UILabel!
    @IBOutlet weak var proteinGramLabel: UILabel!
    @IBOutlet weak var proteinCalLabel: UILabel!
    @IBOutlet weak var fatGramLabel: UILabel!
    @IBOutlet weak var fatCalLabel: UILabel!
    @IBOutlet weak var carbGramLabel: UILabel!
    @IBOutlet weak var carbCalLabel: UILabel!
    
    private let viewModel = PFCViewModel()
    private lazy var input: PFCViewModelInput = viewModel
    private lazy var output: PFCViewModelOutput = viewModel
    private let disposeBug = DisposeBag()
    
    var pChartValue:Int = Int()
    var fChartValue:Int = Int()
    var cChartValue:Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetUp()
        chartViewSetUp()
        chartView.isHidden = true
        outputBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        output.update()
    }
    
    @IBAction func changedSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            chartView.isHidden = true
            pfcStac.isHidden = false
        case 1:
            chartView.isHidden = false
            chartViewSetUp()
            pfcStac.isHidden = true
        default:
            break
        }
    }
    
    @objc func tapAddbutton() {
        let vc = UIStoryboard.init(name: "AddInfo", bundle: nil).instantiateInitialViewController() as! AddInfoViewController
        self.present(vc, animated: true)
    }
    
    @IBAction func tapShowListButton(_ sender: Any) {
        let vc = UIStoryboard.init(name: "PFCList", bundle: nil).instantiateInitialViewController() as! PFCListViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func outputBind() {
        output.models.bind(onNext: { [self] response in
            totalCalLabel.text = "\(response.map {$0.calorie}.reduce(0, +).description)kcal"
            proteinGramLabel.text = response.map {$0.protein}.reduce(0, +).description
            fatGramLabel.text = response.map {$0.fat}.reduce(0, +).description
            carbGramLabel.text = response.map {$0.carb}.reduce(0, +).description
            
            let totalC = response.map {$0.calorie}.reduce(0, +)
            pChartValue = response.map {$0.protein}.reduce(0, +) * 4
            fChartValue = response.map {$0.fat}.reduce(0, +) * 9
            cChartValue = response.map {$0.carb}.reduce(0, +) * 4
            
            
        }).disposed(by: disposeBug)
    }
    
    
    
    
    
    
    
    
    
}

extension HomePFCViewController {
    //UIのセットアップ
    func uiSetUp() {
        mainTopVew.layer.cornerRadius = 20
        mainTopVew.layer.shadowOpacity = 0.5
        mainTopVew.layer.shadowRadius = 3
        mainTopVew.layer.shadowColor = UIColor.darkGray.cgColor
        mainTopVew.layer.shadowOffset = CGSize(width: 5, height: 5)
        diffCalLabel.layer.cornerRadius = 20
        
        addButton.layer.cornerRadius = 25
        addButton.layer.shadowOpacity = 0.5
        addButton.layer.shadowRadius = 3
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        totalCalView.layer.cornerRadius = 20
        totalCalView.layer.shadowOpacity = 0.5
        totalCalView.layer.shadowRadius = 2
        totalCalView.layer.shadowColor = UIColor.gray.cgColor
        totalCalView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        proteinBackView.layer.cornerRadius = 20
        proteinBackView.layer.shadowOpacity = 0.5
        proteinBackView.layer.shadowRadius = 2
        proteinBackView.layer.shadowColor = UIColor.gray.cgColor
        proteinBackView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        fatBackView.layer.cornerRadius = 20
        fatBackView.layer.shadowOpacity = 0.5
        fatBackView.layer.shadowRadius = 2
        fatBackView.layer.shadowColor = UIColor.gray.cgColor
        fatBackView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        carbBackView.layer.cornerRadius = 20
        carbBackView.layer.shadowOpacity = 0.5
        carbBackView.layer.shadowRadius = 2
        carbBackView.layer.shadowColor = UIColor.gray.cgColor
        carbBackView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        proteinLabelView.layer.cornerRadius = 20
        proteinLabelView.layer.shadowOpacity = 0.5
        proteinLabelView.layer.shadowRadius = 2
        proteinLabelView.layer.shadowColor = UIColor.gray.cgColor
        proteinLabelView.layer.shadowOffset = CGSize(width: 2, height: 2)
    
        fatLabelView.layer.cornerRadius = 20
        fatLabelView.layer.shadowOpacity = 0.5
        fatLabelView.layer.shadowRadius = 2
        fatLabelView.layer.shadowColor = UIColor.gray.cgColor
        fatLabelView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
    
        
        carbLabelView.layer.cornerRadius = 20
        carbLabelView.layer.shadowOpacity = 0.5
        carbLabelView.layer.shadowRadius = 2
        carbLabelView.layer.shadowColor = UIColor.gray.cgColor
        carbLabelView.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        
        addButton.addTarget(self, action: #selector(tapAddbutton), for: .touchUpInside)
    }
    
    func chartViewSetUp() {
        // 円グラフの中心に表示するタイトル
        self.chartView.centerText = "PFCバランス"
        // グラフに表示するデータのタイトルと値
        let dataEntries = [
            PieChartDataEntry(value: Double(pChartValue), label: "タンパク質"),
            PieChartDataEntry(value: Double(fChartValue), label: "脂質"),
            PieChartDataEntry(value: Double(cChartValue), label: "炭水化物"),
        ]
        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        // グラフの色
        dataSet.colors = ChartColorTemplates.vordiplom()
        
        // グラフのデータの値の色
        dataSet.valueTextColor = UIColor.black
        // グラフのデータのタイトルの色
        dataSet.entryLabelColor = UIColor.black
        self.chartView.data = PieChartData(dataSet: dataSet)
        // データを％表示にする
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 1.0
        self.chartView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        self.chartView.usePercentValuesEnabled = true
        view.addSubview(self.chartView)
    }
}
