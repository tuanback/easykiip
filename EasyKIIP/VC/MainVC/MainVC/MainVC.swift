//
//  MainVC.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/05/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EasyKIIPKit

public class MainVC: NiblessViewController {
  
  private let viewModel: MainViewModel
  
  private let makeBookDetailVCFactory: ((Book) -> (BookDetailVC))
  
  private let disposeBag = DisposeBag()
  
  public init(viewModel: MainViewModel,
              bookDetailVCFactory: @escaping ((Book) -> (BookDetailVC))) {
    self.viewModel = viewModel
    self.makeBookDetailVCFactory = bookDetailVCFactory
    super.init()
  }
  
  public override func loadView() {
    view = MainRootView(viewModel: viewModel)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupNavBar()
    observeViewModel()
  }
  
  func setupNavBar() {
    navigationItem.title = "KIIP"
    
    let searchController = UISearchController(searchResultsController: nil)
    navigationItem.searchController = searchController
    
    //navigationController?.navigationBar.prefersLargeTitles = true
    
    /*
     let frame = CGRect(x: 0, y: 0, width: 300, height: 30)
     let titleView = UILabel(frame: frame)
     titleView.text = "Test"
     titleView.textColor = UIColor.appLabelColor
     navigationItem.titleView = titleView
     */
  }
  
  private func observeViewModel() {
    viewModel.oNavigation
      .subscribe(onNext: { [weak self] event in
        switch event {
        case .push(let view):
          switch view {
          case .bookDetail(let book):
            if let book = book,
              let vc = self?.makeBookDetailVCFactory(book) {
              self?.navigationController?.pushViewController(vc, animated: true)
            }
          default:
            break
          }
        case .present(_):
          break
        case .pop:
          self?.navigationController?.popViewController(animated: true)
        case .dismiss:
          self?.dismiss(animated: true, completion: nil)
        }
      })
      .disposed(by: disposeBag)
  }
  
}
