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
import DZNEmptyDataSet


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
            pfcTableView.dataSource = self
            pfcTableView.delegate = self
            pfcTableView.emptyDataSetSource = self
            pfcTableView.emptyDataSetDelegate = self
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
        cell.flagSwich.tag = indexPath.row
        cell.catchFlagDelegate = self
        cell.countStepper.tag = indexPath.row
        cell.catchCountDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Edit", bundle: nil).instantiateInitialViewController() as! EditViewController
        vc.row = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
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
    func catchCount(row: Int, value: Int) {
        input.catchCount(row: row, value: value)
    }
}

extension PFCListViewController: CatchFlagProtcol {
    func CatchFlag(row: Int, flag: Bool) {
        input.catchFlag(row: row, flag: flag)
    }
}

extension PFCListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "データがありません")
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "list")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
      return NSAttributedString(string: "ホーム画面から追加しましょう")
     }
}

