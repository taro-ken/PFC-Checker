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
    
    
    private let viewModel = PFCViewModel()
    private lazy var input: PFCViewModelInput = viewModel
    private lazy var output: PFCViewModelOutput = viewModel
    private let disposeBug = DisposeBag()
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    
    var pChartValue:Int = Int()
    var fChartValue:Int = Int()
    var cChartValue:Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .darkGray
        uiSetUp()
        chartViewSetUp()
        chartView.isHidden = true
        outputBind()
        BetterSegmentedControlSetUp()
        generator.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        output.update()
        userDefaultsSetUp()
    }
    
    @objc func changedSegment(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            chartView.isHidden = true
            pfcStac.isHidden = false
        } else {
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
        let vc = UIStoryboard.init(name: "PFCList", bundle: nil).instantiateInitialViewController() as! PFCListViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tappedBMR(_ sender: Any) {
        let vc = UIStoryboard.init(name: "BMR", bundle: nil).instantiateInitialViewController() as! BMRViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func outputBind() {
        output.models.bind(onNext: { [self] response in
            totalCalLabel.text = "\(response.map {$0.calorie}.reduce(0, +).description)kcal"
            proteinGramLabel.text = "\(response.map {$0.protein}.reduce(0, +).description)g"
            fatGramLabel.text = "\(response.map {$0.fat}.reduce(0, +).description)g"
            carbGramLabel.text = "\(response.map {$0.carb}.reduce(0, +).description)g"
            let totalCal = response.map {$0.calorie}.reduce(0, +)
            let totalP = response.map {$0.protein}.reduce(0, +) * 4
            let totalF = response.map {$0.fat}.reduce(0, +) * 9
            let totalC = response.map {$0.carb}.reduce(0, +) * 4
            pChartValue = calculation.calculation(totalPFC: totalP, totalCal: totalCal)
            fChartValue = calculation.calculation(totalPFC: totalF, totalCal: totalCal)
            cChartValue = calculation.calculation(totalPFC: totalC, totalCal: totalCal)
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
        mainTopVew.layer.shadowColor = UIColor.gray.cgColor
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
                                            normalTextColor: .black,
                                            selectedTextColor: .white),
            options:[.backgroundColor(.systemBackground),
                     .indicatorViewBackgroundColor(UIColor.darkGray),
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
    
    func userDefaultsSetUp() {
        let jsonDecoder = JSONDecoder()
     //   jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let data = UserDefaults.standard.data(forKey: "a"),
              let dataModel = try? jsonDecoder.decode(BMRModel.self, from: data) else {
                  return
              }
        print(dataModel)
        totalBMRLabel.text = "1日の総消費カロリー\(dataModel.total)kcal" ?? "未設定"
    }
}
