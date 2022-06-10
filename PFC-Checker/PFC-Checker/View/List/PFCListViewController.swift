//
//  PFCListViewController.swift
//  PFCCal-App
//
//  Created by 木元健太郎 on 2022/06/03.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift


final class PFCListViewController: UIViewController {
    
    private let pfcListCell = "PFCListCell"
    private let viewModel = PFCViewModel()
    lazy var input: PFCViewModelInput = viewModel
     lazy var output: PFCViewModelOutput = viewModel
    private let disposeBug = DisposeBag()
    private var editflag = false
    let realm = try! Realm()
    var pfcComponentModel:Results<PFCcomponentModel>!

    
    @IBOutlet weak var pfcTableView: UITableView! {
        didSet {
            pfcTableView.register(UINib(nibName: pfcListCell, bundle: nil), forCellReuseIdentifier: pfcListCell)
            pfcTableView.layer.cornerRadius = 20
            pfcTableView.dataSource = self
            pfcTableView.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.pfcTableView.reloadData()
        bind()
    }
    
    func bind() {
        output.changeModelsObservable.subscribe(onNext: { dd in
            self.pfcTableView.reloadData()
        })
    }
    
    @IBAction func doneEditTable(_ sender: Any) {
        if editflag == true {
            editflag = false
        } else {
            editflag = true
        }
        pfcTableView.setEditing(editflag, animated: true)
        pfcTableView.isEditing = editflag
    }
}

extension PFCListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output.pfcModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: pfcListCell, for: indexPath) as? PFCListCell else {
            return UITableViewCell()
        }
        cell.configure(model: output.pfcModels[indexPath.row])
        cell.selectionStyle = .none
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.flagSwich.tag = indexPath.row
        cell.catchFlagDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Edit", bundle: nil).instantiateInitialViewController() as! EditViewController
        vc.row = indexPath.row
        self.present(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try! realm.write {
                realm.delete(self.output.pfcModels[indexPath.row])
              }
            output.update()
        }
    }
}

extension PFCListViewController: CatchCountProtcol {
    func catchCount(row: Int, value: Int, flag: Bool) {
    }
}

extension PFCListViewController: CatchFlagProtcol {
    func CatchFlag(row: Int, flag: Bool) {
        input.catchFlag(row: row, flag: flag)
    }
}

