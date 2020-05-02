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

public class MainVC: NiblessViewController {

  private let viewModel: MainViewModel
  
  public init(viewModel: MainViewModel) {
    self.viewModel = viewModel
    super.init()
  }
  
  public override func loadView() {
    view = MainRootView(viewModel: viewModel)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupNavBar()
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

}
