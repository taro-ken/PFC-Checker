//
//  HomePFCViewController.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/05/31.
//

import UIKit
import Charts
import RxSwift
import BetterSegmentedControl

final class HomePFCViewController: UIViewController {
    
    @IBOutlet weak var mainTopVew: UIView!
    @IBOutlet weak var diffCalLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var pfcStac: UIStackView!
    @IBOutlet weak var totalCalLabel: UILabel!
    @IBOutlet weak var proteinGramLabel: UILabel!
    @IBOutlet weak var fatGramLabel: UILabel!
    @IBOutlet weak var carbGramLabel: UILabel!
    @IBOutlet weak var totalBMRLabel: UILabel!
    
    private let viewModel: ViewModelType = PFCViewModel()
    private let disposeBug = DisposeBag()
    private let generator = UIImpactFeedbackGenerator(style: .heavy)
    
    private  var pChartValue: Int = Int()
    private  var fChartValue: Int = Int()
    private var cChartValue: Int = Int()
    
    private var totalCalValue: Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ButtonColor")
        uiSetUp()
        chartViewSetUp()
        chartView.isHidden = true
        outputBind()
        BetterSegmentedControlSetUp()
        generator.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.output.update()
        userDefaultsSetUp()
    }
    
    @objc func changedSegment(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            generator.impactOccurred()
            chartView.isHidden = true
            pfcStac.isHidden = false
        } else {
            generator.impactOccurred()
            chartView.isHidden = false
            chartViewSetUp()
            pfcStac.isHidden = true
        }
    }
    
    @objc func tapAddbutton() {
        generator.impactOccurred()
        let vc = UIStoryboard.init(name: "AddInfo", bundle: nil).instantiateInitialViewController() as! AddInfoViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tapShowListButton(_ sender: Any) {
        generator.impactOccurred()
        let vc = UIStoryboard.init(name: "PFCList", bundle: nil).instantiateInitialViewController() as! PFCListViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tappedBMR(_ sender: Any) {
        generator.impactOccurred()
        if UserDefaults.standard.object(forKey: "a") == nil {
            let vc = UIStoryboard.init(name: "BMR", bundle: nil).instantiateInitialViewController() as! BMRViewController
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard.init(name: "EditBMR", bundle: nil).instantiateInitialViewController() as! EditBMRViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func outputBind() {
        viewModel.output.models.bind(onNext: { [self] response in
            let totalCal = response.map {$0.totalCal}.reduce(0, +)
            let totalP = response.map {$0.totalProtein}.reduce(0, +)
            let totalF = response.map {$0.totalFat}.reduce(0, +)
            let totalC = response.map {$0.totalCarb}.reduce(0, +)
            totalCalValue = Int(totalCal)
            totalCalLabel.text = "\(calculation.doubleToString(value: totalCal))kcal"
            proteinGramLabel.text = "\(calculation.doubleToString(value: totalP))g"
            fatGramLabel.text = "\(calculation.doubleToString(value: totalF))g"
            carbGramLabel.text = "\(calculation.doubleToString(value: totalC))g"
            pChartValue = calculation.calculation(totalPFC: totalP * 4, totalCal: totalCal)
            fChartValue = calculation.calculation(totalPFC: totalF * 9, totalCal: totalCal)
            cChartValue = calculation.calculation(totalPFC: totalC * 4, totalCal: totalCal)
        }).disposed(by: disposeBug)
    }
}

extension HomePFCViewController {
    //UIのセットアップ
    func uiSetUp() {
        totalCalLabel.font = UIFont(name: "pingfanghk-Medium", size: 45)
        
        mainTopVew.layer.cornerRadius = 20
        mainTopVew.layer.shadowOpacity = 0.5
        mainTopVew.layer.shadowRadius = 2
        mainTopVew.layer.shadowColor = UIColor.black.cgColor
        mainTopVew.layer.shadowOffset = CGSize(width: 2, height: 2)
        diffCalLabel.layer.cornerRadius = 20
        
        addButton.layer.cornerRadius = 25
        addButton.layer.shadowOpacity = 0.5
        addButton.layer.shadowRadius = 2
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        addButton.addTarget(self, action: #selector(tapAddbutton), for: .touchUpInside)
    }
    
    //BetterSegmentedControlのセットアップ
    func BetterSegmentedControlSetUp() {
        let noSelectedSegmentControl = BetterSegmentedControl(
            frame: CGRect(x: 0, y: 0, width: 180.0, height: 30.0),
            segments: LabelSegment.segments(withTitles: ["PFC(g)", "PFC(%)"],
                                            normalTextColor: .white,
                                            selectedTextColor: .black),
            options:[.backgroundColor(.darkGray),
                     .indicatorViewBackgroundColor(.white),
                     .cornerRadius(15.0),
                     .animationSpringDamping(1.0)])
        noSelectedSegmentControl.addTarget(self, action: #selector(changedSegment(_:)), for: .valueChanged)
        navigationItem.titleView = noSelectedSegmentControl
    }
    
    //Chartsのセットアップ
    func chartViewSetUp() {
        self.chartView.centerText = "PFCバランス"
        chartView.animate(xAxisDuration: 0.5)
        let dataEntries = [
            PieChartDataEntry(value: Double(pChartValue) / 100, label: "タンパク質"),
            PieChartDataEntry(value: Double(fChartValue) / 100, label: "脂質"),
            PieChartDataEntry(value: Double(cChartValue) / 100, label: "炭水化物"),
        ]
        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        //  dataSet.colors = ChartColorTemplates.vordiplom()
        dataSet.colors = [UIColor(named: "PColor")!,UIColor(named: "FColor")!,UIColor(named: "CColor")!]
        dataSet.valueTextColor = UIColor.black
        dataSet.entryLabelColor = UIColor.black
        self.chartView.data = PieChartData(dataSet: dataSet)
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        self.chartView.data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        view.addSubview(self.chartView)
    }
    
    //代謝データの取得
    func userDefaultsSetUp() {
        let jsonDecoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: "a"),
              let dataModel = try? jsonDecoder.decode(BMRModel.self, from: data),
              let totalBMR = Int(dataModel.total) else {
            return
        }
        let diffCalValue = totalCalValue - totalBMR
        if totalBMR == 0 {
            totalBMRLabel.text = "消費カロリーを設定してください"
        } else {
            totalBMRLabel.text = "1日の総消費カロリー\(dataModel.total)kcal"
        }
        
        if diffCalValue < 0 {
            diffCalLabel.textColor = UIColor(named: "-Color")
            diffCalLabel.text = "\(diffCalValue)kcal"
        } else if diffCalValue > 0 {
            diffCalLabel.textColor = UIColor(named: "+Color")
            diffCalLabel.text = "+\(diffCalValue)kcal"
        }
    }
}
