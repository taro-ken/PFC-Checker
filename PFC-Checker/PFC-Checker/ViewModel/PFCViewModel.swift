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
    func addInfo(name: String?, protein: Double, fat: Double, carb: Double, calorie: Double, unit: String?, unitValue: Int, flag: Bool)
    func catchCount(row: Int, value: Int)
    func catchFlag(row: Int, flag: Bool)
    func editInfo(name: String?, protein: Double, fat: Double, carb: Double, calorie: Double, unit: String?, flag: Bool, row: Int)
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
    func addInfo(name: String?,protein: Double,fat: Double,carb: Double,calorie: Double,unit: String?,unitValue: Int,flag: Bool) {
        guard let unit = unit else {
            return
        }
        let pfc = PFCcomponentModel()
        pfc.name = name
        pfc.protein = protein * Double(unitValue)
        pfc.fat = fat * Double(unitValue)
        pfc.carb = carb * Double(unitValue)
        pfc.calorie = calorie * Double(unitValue)
        pfc.unit = unit
        pfc.unitValue = unitValue
        pfc.flag = flag
        try! realm.write() {
            realm.add(pfc)
            update()
        }
    }
    
    func editInfo(name: String?, protein: Double, fat: Double, carb: Double, calorie: Double, unit: String?, flag: Bool, row: Int) {
        let pfcData = realm.objects(PFCcomponentModel.self)
        let unitValue = pfcData[row].unitValue
        guard let unit = unit else {
            return
        }
        try! realm .write {
            pfcData[row].name = name
            pfcData[row].protein = protein * Double(unitValue)
            pfcData[row].fat = fat * Double(unitValue)
            pfcData[row].carb = carb * Double(unitValue)
            pfcData[row].calorie = calorie * Double(unitValue)
            pfcData[row].unit = unit
            pfcData[row].flag = flag
            update()
        }
    }
    
    func catchCount(row: Int, value: Int) {
        let pfc = PFCcomponentModel()
        let pfcData = realm.objects(PFCcomponentModel.self)
        let baseP = pfcData[row].protein / Double(pfcData[row].unitValue)
        let baseF = pfcData[row].fat / Double(pfcData[row].unitValue)
        let baseC = pfcData[row].carb / Double(pfcData[row].unitValue)
        let baseCalorie = pfcData[row].calorie / Double(pfcData[row].unitValue)
        
        try! realm.write {
            pfcData[row].unitValue = (pfcData[row].unitValue / pfcData[row].unitValue) * value
            pfcData[row].protein = baseP * Double(value)
            pfcData[row].fat = baseF * Double(value)
            pfcData[row].carb = baseC * Double(value)
            pfcData[row].calorie = baseCalorie * Double(value)
            update()
        }
    }
    
    func catchFlag(row: Int, flag: Bool) {
        print(row)
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


