//
//  PFCViewModel.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/06/02.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import UIKit

protocol PFCViewModelInput {
    func addInfo(name: String?,protein: Int,fat: Int,carb: Int,calorie: Int,unit: String?,unitValue: Int,flag: Bool)
    func catchCount(row: Int, value: Int, flag: Bool)
    func catchFlag(row: Int, flag: Bool)
    func editInfo(name: String?,protein: Int,fat: Int,carb: Int,calorie: Int,unit: String?,unitValue: Int,flag: Bool,row: Int)
    var pValue: BehaviorRelay<Double?> { get }
    var fValue: BehaviorRelay<Double?> { get }
    var cValue: BehaviorRelay<Double?> { get }
    var calValue: BehaviorRelay<Double?> { get }
    func calorieSet()
    func savedBMR(sex: String?, age: Double?, tool: Double?, weight: Double? ,active: String?, emr: Double?, totalEMR: Double?)
    func calculationBMR(sex: Observable<Int>, age: Observable<Double>, tool: Observable<Double>, weight: Observable<Double>, active: Observable<Int>)
}

protocol PFCViewModelOutput {
    var changeModelsObservable: Observable<Void> { get }
    var pfcModels: [PFCcomponentModel] { get }
    func update()
    var models:BehaviorRelay<[PFCcomponentModel]> { get }
    var bmrValue: BehaviorRelay<String> { get }
    var totalBMRValue: BehaviorRelay<String> { get }
}


final class PFCViewModel: PFCViewModelInput, PFCViewModelOutput {
    
    
    private let realm = try! Realm()
    private let disposeBug = DisposeBag()
    
    var pValue = BehaviorRelay<Double?>(value: Double())
    var fValue = BehaviorRelay<Double?>(value: Double())
    var cValue = BehaviorRelay<Double?>(value: Double())
    var calValue = BehaviorRelay<Double?>(value: Double())
    
    
    //MARK: -/*inputについての記述*/
    private let addInfo = PublishRelay<PFCcomponentModel>()
    func addInfo(name: String?,protein: Int,fat: Int,carb: Int,calorie: Int,unit: String?,unitValue: Int,flag: Bool) {
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
        pfc.flag = flag
        
        try! realm.write() {
            realm.add(pfc)
            update()
        }
    }
    
    func editInfo(name: String?,protein: Int,fat: Int,carb: Int,calorie: Int,unit: String?,unitValue: Int,flag: Bool, row: Int) {
        let realmModel = realm.objects(PFCcomponentModel.self)
        guard let unit = unit else {
            return
        }
        
        try! realm .write {
            realmModel[row].name = name
            realmModel[row].protein = protein
            realmModel[row].fat = fat
            realmModel[row].carb = carb
            realmModel[row].calorie = calorie
            realmModel[row].unit = unit
            realmModel[row].unitValue = unitValue
            realmModel[row].flag = flag
            update()
        }
    }
    
    func catchCount(row: Int, value: Int, flag: Bool) {
        let pfc = PFCcomponentModel()
        
        let pfcData = realm.objects(PFCcomponentModel.self).filter("flag == %d",flag)
        
        let baseP = pfcData[row].protein / pfcData[row].unitValue
        let baseF = pfcData[row].fat / pfcData[row].unitValue
        let baseC = pfcData[row].carb / pfcData[row].unitValue
        let baseCalorie = pfcData[row].calorie / pfcData[row].unitValue
        
        try! realm.write {
            pfcData[row].unitValue = (pfcData[row].unitValue / pfcData[row].unitValue) * value
            pfcData[row].protein = baseP * value
            pfcData[row].fat = baseF * value
            pfcData[row].calorie = baseCalorie * value
        }
    }
    
    func catchFlag(row: Int, flag: Bool) {
        print(row)
        let pfcData = realm.objects(PFCcomponentModel.self)
        try! realm.write {
            pfcData[row].flag = flag
            update()
            print(realm.objects(PFCcomponentModel.self))
        }
        
    }
    
    func calorieSet() {
        let pObservable =  Observable<Double>.create { [self] observer -> Disposable in
            pValue.bind { response in
                guard let response = response else {
                    return
                }
                observer.onNext(response)
                observer.onCompleted()
            }.disposed(by: disposeBug)
            return Disposables.create()
        }
        
        let fObservable =  Observable<Double>.create { [self] observer -> Disposable in
            fValue.bind { response in
                guard let response = response else {
                    return
                }
                observer.onNext(response)
                observer.onCompleted()
            }.disposed(by: disposeBug)
            return Disposables.create()
        }
        
        let cObservable =  Observable<Double>.create { [self] observer -> Disposable in
            cValue.bind { response in
                guard let response = response else {
                    return
                }
                observer.onNext(response)
                observer.onCompleted()
            }.disposed(by: disposeBug)
            return Disposables.create()
        }
        
        Observable.combineLatest(pObservable,fObservable,cObservable).map{ [self] p,f,c in
            let mix = (p * 4)+(f * 9)+(c * 4)
            calValue.accept(mix)
        }.subscribe().disposed(by: disposeBug)
    }
    
    func calculationBMR(sex: Observable<Int>, age: Observable<Double>, tool: Observable<Double>, weight: Observable<Double>,  active: Observable<Int>) {
        sex.bind { [self] response in
            if response == 0 {
                Observable
                    .combineLatest(age, tool, weight) { (_age: Double, _tool: Double, _weight: Double) in
                        calculation.menBMRCalculation(age: _age, tool: _tool, weight: _weight)
                    }
                    .map { String(format: "%.0f",$0) }
                    .bind(to: bmrValue)
                    .disposed(by: disposeBug)
            } else {
                Observable
                    .combineLatest(age, tool, weight) { (_age: Double, _tool: Double, _weight: Double) in
                        calculation.womanBMRCalculation(age: _age, tool: _tool, weight: _weight)
                    }
                    .map { String(format: "%.0f",$0) }
                    .bind(to: bmrValue)
                    .disposed(by: disposeBug)
            }
        }
        
        active.bind { [self] response in
            switch response {
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
    }
    
    func savedBMR(sex: String?, age: Double?, tool: Double?, weight: Double? ,active: String?, emr: Double?, totalEMR: Double?) {
        
    }
    
    
    //MARK: - outputについての記述
    private let _changeModelsObservable = PublishRelay<Void>()
    lazy var changeModelsObservable = _changeModelsObservable.asObservable()
    private(set) var pfcModels:[PFCcomponentModel] = []
    private(set) var models = BehaviorRelay<[PFCcomponentModel]>(value: [])
    
    var bmrValue = BehaviorRelay<String>(value: String())
    var totalBMRValue = BehaviorRelay<String>(value: String())
    
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


