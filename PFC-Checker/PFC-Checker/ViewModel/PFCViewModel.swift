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

//ViewModelの入力に関するprotocol
protocol PFCViewModelInput {
    func addInfo(name: String?,protein: Int,fat: Int,carb: Int,calorie: Int,unit: String?,unitValue: Int,flag: Bool)
    func catchCount(row: Int, value: Int, flag: Bool)
    func catchFlag(row: Int, flag: Bool)
    func editInfo(name: String?,protein: Int,fat: Int,carb: Int,calorie: Int,unit: String?,unitValue: Int,flag: Bool,row: Int)
}

//ViewModelの出力に関するprotocol
protocol PFCViewModelOutput {
    var changeModelsObservable: Observable<Void> { get }
    var pfcModels: [PFCcomponentModel] { get }
    func update()
    var models:BehaviorRelay<[PFCcomponentModel]> { get }
}

//ViewModelはInputとOutputのprotocolに準拠する
final class PFCViewModel: PFCViewModelInput, PFCViewModelOutput {
   
    private let realm = try! Realm()
    private let disposeBug = DisposeBag()
    
    
    /*inputについての記述*/
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
    
    
    
    
    /*outputについての記述*/
    private let _changeModelsObservable = PublishRelay<Void>()
    lazy var changeModelsObservable = _changeModelsObservable.asObservable()
    private(set) var pfcModels:[PFCcomponentModel] = []
    private(set) var models = BehaviorRelay<[PFCcomponentModel]>(value: [])
    
    
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


