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
  
  private let makeBookDetailVCFactory: ((Int, String) -> (BookDetailVC))
  
  private let disposeBag = DisposeBag()
  
  public init(viewModel: MainViewModel,
              bookDetailVCFactory: @escaping ((Int, String) -> (BookDetailVC))) {
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
  
  deinit {
    print("Deinit")
  }
  
  func setupNavBar() {
    navigationItem.title = "KIIP"
    
    let searchController = UISearchController(searchResultsController: nil)
    navigationItem.searchController = searchController
    
    //navigationController?.navigationBar.prefersLargeTitles = true
    
    let signOutBarButton = UIBarButtonItem(title: "Sign out", style: .done, target: self, action: #selector(handleSignoutButtonClicked(_:)))
    
    navigationItem.rightBarButtonItem = signOutBarButton
    /*
     let frame = CGRect(x: 0, y: 0, width: 300, height: 30)
     let titleView = UILabel(frame: frame)
     titleView.text = "Test"
     titleView.textColor = UIColor.appLabelColor
     navigationItem.titleView = titleView
     */
  }
  
  @objc func handleSignoutButtonClicked(_ barButton: UIBarButtonItem) {
    viewModel.handleSignoutClicked()
  }
  
  private func observeViewModel() {
    viewModel.oNavigation
      .subscribe(onNext: { [weak self] event in
        switch event {
        case .push(let view):
          switch view {
          case let .bookDetail(bookID, bookName):
            guard let vc = self?.makeBookDetailVCFactory(bookID, bookName) else { return }
            self?.navigationController?.pushViewController(vc, animated: true)
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
