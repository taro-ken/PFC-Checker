//
//  PFCViewModel.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/06/02.
//

import RxSwift
import RxCocoa
import RealmSwift
import UIKit

protocol PFCViewModelInput {
    func addInfo(name: String?, protein: Double, fat: Double, carb: Double, calorie: Double, unit: String?, countValue: Double, unitValue: Int, flag: Bool)
    func catchCount(row: Int, value: Double)
    func catchFlag(row: Int, flag: Bool)
    func editInfo(name: String?, protein: Double, fat: Double, carb: Double, calorie: Double, unit: String?,unitValue: Int, flag: Bool, row: Int)
    var pValue: BehaviorRelay<Double?> { get }
    var fValue: BehaviorRelay<Double?> { get }
    var cValue: BehaviorRelay<Double?> { get }
    var calValue: BehaviorRelay<Double?> { get }
    func bmrCalculation(sex: Int, age: String?, tool: String?, weight: String?, active: Int)
}

protocol PFCViewModelOutput {
    var changeModelsObservable: Observable<Void> { get }
    var pfcModels: [PFCcomponentModel] { get }
    func update()
    var models:BehaviorRelay<[PFCcomponentModel]> { get }
    var bmrValue: BehaviorRelay<String> { get }
    var totalBMRValue: BehaviorRelay<String> { get }
}

protocol ViewModelType {
  var input: PFCViewModelInput { get }
  var output: PFCViewModelOutput { get }
}


final class PFCViewModel: PFCViewModelInput, PFCViewModelOutput, ViewModelType {
    var input: PFCViewModelInput { return self }
    var output: PFCViewModelOutput { return self }
    
    private let realm = try! Realm()
    private let disposeBug = DisposeBag()
    
    var pValue = BehaviorRelay<Double?>(value: Double())
    var fValue = BehaviorRelay<Double?>(value: Double())
    var cValue = BehaviorRelay<Double?>(value: Double())
    var calValue = BehaviorRelay<Double?>(value: Double())
    
    
    //MARK: -/*inputについての記述*/
    private let addInfo = PublishRelay<PFCcomponentModel>()
    func addInfo(name: String?, protein: Double, fat: Double, carb: Double, calorie: Double, unit: String?, countValue: Double, unitValue: Int, flag: Bool) {
        guard let unit = unit else {
            return
        }
        let pfc = PFCcomponentModel()
        pfc.name = name
        pfc.protein = protein
        pfc.fat = fat
        pfc.carb = carb
        pfc.calorie = calorie
        pfc.unit = unit
        pfc.unitValue = unitValue
        pfc.countValue = countValue
        pfc.flag = flag
        pfc.totalProtein = protein * countValue
        pfc.totalFat = fat * countValue
        pfc.totalCarb = carb * countValue
        pfc.totalCal = calorie * countValue
        try! realm.write() {
            realm.add(pfc)
            update()
        }
    }
    
    func editInfo(name: String?, protein: Double, fat: Double, carb: Double, calorie: Double, unit: String?, unitValue: Int, flag: Bool, row: Int) {
        let pfcData = realm.objects(PFCcomponentModel.self)
        guard let unit = unit else {
            return
        }
        try! realm .write {
            pfcData[row].name = name
            pfcData[row].protein = protein
            pfcData[row].fat = fat
            pfcData[row].carb = carb
            pfcData[row].calorie = calorie
            pfcData[row].unit = unit
            pfcData[row].unitValue = unitValue
            pfcData[row].flag = flag
            pfcData[row].totalProtein = protein * pfcData[row].countValue
            pfcData[row].totalFat = fat * pfcData[row].countValue
            pfcData[row].totalCarb = carb * pfcData[row].countValue
            pfcData[row].totalCal = calorie * pfcData[row].countValue
            update()
        }
    }
    
    func catchCount(row: Int, value: Double) {
        let pfcData = realm.objects(PFCcomponentModel.self)
        let baseP = pfcData[row].totalProtein / pfcData[row].countValue
        let baseF = pfcData[row].totalFat / pfcData[row].countValue
        let baseC = pfcData[row].totalCarb / pfcData[row].countValue
        let baseCalorie = pfcData[row].totalCal / pfcData[row].countValue
        
        try! realm.write {
            pfcData[row].countValue = value
            pfcData[row].totalProtein = baseP * value
            pfcData[row].totalFat = baseF * value
            pfcData[row].totalCarb = baseC * value
            pfcData[row].totalCal = baseCalorie * value
            update()
        }
    }
    
    func catchFlag(row: Int, flag: Bool) {
        let pfcData = realm.objects(PFCcomponentModel.self)
        try! realm.write {
            pfcData[row].flag = flag
            update()
        }
    }
    
    func bmrCalculation(sex: Int, age: String?, tool: String?, weight: String?, active: Int) {
        guard let _age = age,
              let _tool = tool,
              let _weight = weight,
              let  __age = Double(_age),
              let __tool = Double(_tool),
              let __weight  = Double(_weight) else {
                  return
              }
        if sex == 0 {
            let men = calculation.menBMRCalculation(age:  __age, tool: __tool, weight: __weight)
            let st = String(format: "%.0f",men)
            bmrValue.accept(st)
        } else {
            let woman = calculation.womanBMRCalculation(age: __age, tool: __tool, weight: __weight)
            let st = String(format: "%.0f",woman)
            bmrValue.accept(st)
        }
        
        switch active {
        case 0:
            bmrValue.map{ String(format: "%.0f",calculation.lowCalculation(value: $0))}.bind(to: totalBMRValue).disposed(by: disposeBug)
        case 1:
            bmrValue.map{ String(format: "%.0f",calculation.middleCalculation(value: $0)) }.bind(to: totalBMRValue).disposed(by: disposeBug)
        case 2:
            bmrValue.map{ String(format: "%.0f",calculation.highCalculation(value: $0)) }.bind(to: totalBMRValue).disposed(by: disposeBug)
        case 3:
            bmrValue.map{ String(format: "%.0f",calculation.superHighCalculation(value: $0)) }.bind(to: totalBMRValue).disposed(by: disposeBug)
        default:
            break
        }
    }
    
    
    //MARK: - outputについての記述
    private let _changeModelsObservable = PublishRelay<Void>()
    lazy var changeModelsObservable = _changeModelsObservable.asObservable()
    private(set) var pfcModels:[PFCcomponentModel] = []
    private(set) var models = BehaviorRelay<[PFCcomponentModel]>(value: [])
    
    let bmrValue = BehaviorRelay<String>(value: String())
    let totalBMRValue = BehaviorRelay<String>(value: String())
    
    
    func update() {
        let pfcData = realm.objects(PFCcomponentModel.self)
        let pfcDataArray = Array(pfcData)
        pfcModels = pfcDataArray
        _changeModelsObservable.accept(())
        let filter = pfcData.filter("flag == %d",true)
        models.accept(Array(filter))
    }
    
    init() {
        let pfcData = realm.objects(PFCcomponentModel.self)
        let pfcDataArray = Array(pfcData)
        pfcModels = pfcDataArray
        let filter = pfcData.filter("flag == %d",true)
        models.accept(Array(filter))
    }
}


