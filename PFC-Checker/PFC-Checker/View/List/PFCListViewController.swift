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
    private let viewModel: ViewModelType = PFCViewModel()
    private let disposeBug = DisposeBag()
    private var editflag = false
    private let generator = UIImpactFeedbackGenerator(style: .heavy)
    private let realm = try! Realm()
    private var pfcComponentModel:Results<PFCcomponentModel>!
    
    
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
        viewModel.output.changeModelsObservable.subscribe(onNext: { dd in
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
        viewModel.output.pfcModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: pfcListCell, for: indexPath) as? PFCListCell else {
            return UITableViewCell()
        }
        cell.configure(model:viewModel.output.pfcModels[indexPath.row])
        cell.selectionStyle = .none
        cell.flagSwich.tag = indexPath.row
        cell.catchFlagDelegate = self
        cell.countChange.tag = indexPath.row
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
                realm.delete(self.viewModel.output.pfcModels[indexPath.row])
            }
            viewModel.output.update()
        }
    }
}

extension PFCListViewController: CatchCountProtcol {
    func catchCount(row: Int) {
        generator.impactOccurred()
    
        let alert = UIAlertController(title: "数量を変更",
                                      message: nil,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addTextField { [self] (textField) in
            textField.placeholder = "数値を入力　例:0.5, 1, 1.5"
            textField.keyboardType = .decimalPad
        }
        alert.addAction(UIAlertAction(title: "保存", style: .default, handler: { [weak self] (_) in
            
            if alert.textFields?.first?.text == "" {
                let dialog = UIAlertController(title: "未入力", message: "数値を入力してください", preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(dialog, animated: true, completion: nil)
                return
            } else if alert.textFields?.first?.text == "0" {
                let dialog = UIAlertController(title: "エラー", message: "0以上の数値を入力してください", preferredStyle: .alert)
                dialog.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(dialog, animated: true, completion: nil)
                return
            }
            guard let text = alert.textFields?.first?.text,
                  let intText = Double(text)  else {
                return
            }
            self?.viewModel.input.catchCount(row: row, value: round(intText * 10) / 10)
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension PFCListViewController: CatchFlagProtcol {
    func CatchFlag(row: Int, flag: Bool) {
        viewModel.input.catchFlag(row: row, flag: flag)
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

