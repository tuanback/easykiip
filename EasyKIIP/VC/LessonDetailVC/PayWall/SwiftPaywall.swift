//
//  SwiftPaywall.swift
//  SwiftExample
//
//  Created by Ryan Kotzebue on 9/13/19.
//  Copyright © 2019 RevenueCat. All rights reserved.
//

import Purchases
import SnapKit
import UIKit
import SVProgressHUD

enum PayWallEdgeStyle : String {
  case square
  case soft
  case round
}

@objc protocol SwiftPaywallDelegate {
  func purchaseCompleted(paywall: SwiftPaywall, transaction: SKPaymentTransaction, purchaserInfo: Purchases.PurchaserInfo)
  @objc optional func purchaseFailed(paywall: SwiftPaywall, purchaserInfo: Purchases.PurchaserInfo?, error: Error, userCancelled: Bool)
  @objc optional func purchaseRestored(paywall: SwiftPaywall, purchaserInfo: Purchases.PurchaserInfo?, error: Error?)
}

class SwiftPaywall: UIViewController {
  
  var delegate : SwiftPaywallDelegate?
  
  // Properties to initialize with
  private var textColor : UIColor
  private var productSelectedColor : UIColor
  private var productDeselectedColor : UIColor
  private var showDiscountPercentage : Bool
  private var edgeStyle : PayWallEdgeStyle
  private var offeringId : String?
  private var termsOfServiceURL = URL(string: "https://tuanback.github.io/ezkiip/terms.html")
  private var privacyPolicyURL = URL(string: "https://tuanback.github.io/ezkiip/privacy.html")
  private var allowRestore : Bool
  
  // Views to optionally customize
  public var headerView: UIView!
  public var titleLabel: UILabel!
  public var subtitleLabel : UILabel!
  public var restoreButton : UIButton!
  public var freeTrialLabel : UILabel!
  public var termsAndConditionsLabel : UILabel!
  
  // Internal variables
  private var stackViewContainer : UIStackView!
  private var offeringCollectionView : UICollectionView!
  private let sectionInsets = UIEdgeInsets(top: 8.0,
                                           left: 8.0,
                                           bottom: 16.0,
                                           right: 8.0)
  
  private var offeringLoadingIndicator : UIActivityIndicatorView!
  private var closeButton : CloseButton!
  
  private var offering: Purchases.Offering?
  private var defaultBuyButtonText : String?
  private var defaultRestoreButtonText : String?
  
  private var didChangePackage = false
  
  private lazy var didPurchasePackageSelected: (Purchases.Package) -> () = { [weak self] package in
    self?.purchaseSelectedPackage(package: package)
  }
  
  init(allowRestore: Bool = true, // Whether your app allows restoring purchases, default is true for most apps
    offeringId: String? = nil, // Offering ID, defaults to the current offering in RevenueCat
    edgeStyle: PayWallEdgeStyle = .round, // Corner radius style, defaults to round
    showDiscountPercentage: Bool = true, // Whether or not to show the discount badge on the products, default to true
    backgroundColor: UIColor = UIColor(red: 0.937, green: 0.286, blue: 0.314, alpha: 1.00), // Background color, defults to RevenueCat red
    textColor: UIColor = UIColor.white, // Text color, defaults to white
    productSelectedColor: UIColor = UIColor.white, // Selected product cell color, defaults to white
    productDeselectedColor: UIColor = UIColor.black) { // Deselected product cell color, defaults to black
    
    self.allowRestore = allowRestore
    self.offeringId = offeringId
    self.edgeStyle = edgeStyle
    self.showDiscountPercentage = showDiscountPercentage
    self.textColor = textColor
    self.productSelectedColor = productSelectedColor
    self.productDeselectedColor = productDeselectedColor
    
    super.init(nibName: nil, bundle: nil)
    view.backgroundColor = UIColor.appRed
    
    buildSubviews()
    loadOfferings()
  }
  
  override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    return .portrait
  }
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .portrait
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  private func loadOfferings() {
    
    offeringLoadingIndicator.startAnimating()
    SVProgressHUD.show()
    
    Purchases.shared.offerings { (offerings, error) in
      
      if error != nil {
        self.showAlert(title: "Error", message: "Unable to fetch offerings.") { (action) in
          self.close()
        }
      }
      if let offeringId = self.offeringId {
        self.offering = offerings?.offering(identifier: offeringId)
      } else {
        self.offering = offerings?.current
      }
      
      if self.offering == nil {
        self.showAlert(title: Strings.error, message: Strings.noOfferingsFound) { (action) in
          self.close()
        }
      }
      
      if let numberOfPackages = self.offering?.availablePackages.count,
        numberOfPackages > 0 {
        self.offeringCollectionView.snp.remakeConstraints { (make) in
          make.height.equalTo(64 * numberOfPackages + Int(self.sectionInsets.bottom) * (numberOfPackages - 1))
        }
      }
      
      self.offeringLoadingIndicator.stopAnimating()
      self.offeringCollectionView.reloadData()
      SVProgressHUD.dismiss()
    }
  }
  
  private func purchaseSelectedPackage(package: Purchases.Package) {
    
    setState(loading: true)
    Purchases.shared.purchasePackage(package) { (trans, info, error, cancelled) in
      
      self.setState(loading: false)
      
      if let error = error {
        if let purchaseFailedHandler = self.delegate?.purchaseFailed {
          purchaseFailedHandler(self, info, error, cancelled)
        } else {
          if !cancelled {
            self.showAlert(title: Strings.failed, message: error.localizedDescription)
          }
        }
      } else  {
        if let purchaseCompletedHandler = self.delegate?.purchaseCompleted {
          purchaseCompletedHandler(self, trans!, info!)
        } else {
          self.close()
        }
      }
    }
  }
  
  @objc private func restorePurchases() {
    setState(loading: true)
    Purchases.shared.restoreTransactions { (info, error) in
      
      self.setState(loading: false)
      
      if let purchaseRestoredHandler = self.delegate?.purchaseRestored {
        purchaseRestoredHandler(self, info, error)
      } else {
        if let error = error {
          self.showAlert(title: "Error", message: error.localizedDescription)
        } else {
          if let purchaserInfo = info {
            if purchaserInfo.entitlements.active.isEmpty {
              self.showAlert(title: "Restore Unsuccessful", message: "No prior purchases found for your account.")
            } else {
              self.close()
            }
          }
        }
      }
    }
  }
  
  @objc private func close() {
    dismiss(animated: true, completion: nil)
  }
  
  @objc private func tapToCs(tap: UITapGestureRecognizer) {
    guard let text = termsAndConditionsLabel.text else {
      return
    }
    guard let tocRange = termsAndConditionsLabel.text?.range(of: Strings.termsOfService) else {
      return
    }
    guard let privacyRange = termsAndConditionsLabel.text?.range(of: Strings.privacyPolicy) else {
      return
    }
    
    if tap.didTapAttributedTextInLabel(label: termsAndConditionsLabel, inRange: NSRange(tocRange, in: text)) {
      if let url = termsOfServiceURL {
        let nav = UINavigationController(rootViewController: WebViewController(url: url, title: Strings.termsOfService, textColor: view.backgroundColor, barColor: textColor))
        present(nav, animated: true, completion: nil)
      }
    } else if tap.didTapAttributedTextInLabel(label: termsAndConditionsLabel, inRange: NSRange(privacyRange, in: text)) {
      if let url = privacyPolicyURL {
        let nav = UINavigationController(rootViewController: WebViewController(url: url, title: Strings.privacyPolicy, textColor: view.backgroundColor, barColor: textColor))
        present(nav, animated: true, completion: nil)
      }
    }
  }
  
  // Only call this right before purchasing or restoring
  private func setState(loading: Bool) {
    if loading {
      
      // This is to preserve the current button text after loading is shown
      defaultRestoreButtonText = restoreButton.titleLabel?.text
      
      SVProgressHUD.show()
      
      restoreButton.isEnabled = false
      restoreButton.setTitle(Strings.loading, for: .normal)
      
      offeringCollectionView.isUserInteractionEnabled = false
      
      closeButton.isHidden = true
    } else {
      SVProgressHUD.dismiss()
      
      restoreButton.isEnabled = true
      restoreButton.setTitle(defaultRestoreButtonText, for: .normal)
      
      offeringCollectionView.isUserInteractionEnabled = true
      
      closeButton.isHidden = false
    }
  }
  
  private func shouldShowDiscount(package: Purchases.Package?) -> (Bool, Purchases.Package?) {
    return (showDiscountPercentage == true
      && mostAffordablePackages.count > 1
      && mostAffordablePackages.last?.product.productIdentifier != package?.product.productIdentifier, mostAffordablePackages.last)
  }
  
  private var mostAffordablePackages : [Purchases.Package] {
    guard let sorted = offering?.availablePackages
      .filter({$0.packageType != .lifetime && $0.packageType != .custom})
      .sorted(by: { $1.annualCost() > $0.annualCost() }) else {
        return []
    }
    return sorted
  }
  
  private func showAlert(title: String?, message: String?, handler: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: Strings.ok, style: .default, handler: handler))
    self.present(alert, animated: true, completion: nil)
  }
  
  private func buildSubviews() {
    
    // The scrollView
    stackViewContainer = UIStackView()
    stackViewContainer.alignment = .fill
    stackViewContainer.distribution = .fill
    stackViewContainer.axis = .vertical
    stackViewContainer.spacing = 16
    stackViewContainer.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(stackViewContainer)
    
    stackViewContainer.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.leading.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
    }
    
    // The header is a UIView for customization
    headerView = UIView()
    stackViewContainer.addArrangedSubview(headerView)
    
    headerView.snp.makeConstraints { (make) in
      make.height.equalTo(stackViewContainer).multipliedBy(0.15)
    }
    
    // The title label
    titleLabel = UILabel()
    titleLabel.numberOfLines = 0
    titleLabel.minimumScaleFactor = 0.01
    titleLabel.textAlignment = .center
    titleLabel.font = UIFont.boldSystemFont(ofSize: 26)
    titleLabel.textColor = textColor
    titleLabel.text = Strings.benefit_unlockEverything
    headerView.addSubview(titleLabel)
    
    titleLabel.snp.makeConstraints { (make) in
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(16)
      make.height.equalTo(44)
    }
    
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .left
    paragraph.lineSpacing = 8
    let textAttributes = [NSAttributedString.Key.font: UIFont.appFontDemiBold(ofSize: 16),
                          NSAttributedString.Key.paragraphStyle: paragraph]
    let baseText = Strings.benefit_synchronizeBetweenMultipleDevices + "\n" + Strings.benefit_learnOffline + "\n" + Strings.benefit_noAds
    let benefitStr = NSAttributedString(string: baseText, attributes: textAttributes)
    
    subtitleLabel = UILabel()
    subtitleLabel.numberOfLines = 0
    subtitleLabel.minimumScaleFactor = 0.01
    subtitleLabel.textAlignment = .left
    subtitleLabel.textColor = textColor
    subtitleLabel.alpha = 0.90
    subtitleLabel.attributedText = benefitStr
    stackViewContainer.addArrangedSubview(subtitleLabel)
    
    subtitleLabel.snp.makeConstraints { (make) in
      make.height.equalTo(120)
    }
    
    // The offering container
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    offeringCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    offeringCollectionView.delegate = self
    offeringCollectionView.dataSource = self
    offeringCollectionView.showsHorizontalScrollIndicator = false
    offeringCollectionView.register(PackageCell.self, forCellWithReuseIdentifier: "cell")
    offeringCollectionView.translatesAutoresizingMaskIntoConstraints = false
    offeringCollectionView.backgroundColor = .clear
    stackViewContainer.addArrangedSubview(offeringCollectionView)
    
    // The offerings loading indicator
    offeringLoadingIndicator = UIActivityIndicatorView(style: .gray)
    offeringLoadingIndicator.hidesWhenStopped = true
    offeringLoadingIndicator.translatesAutoresizingMaskIntoConstraints = false
    offeringCollectionView.addSubview(offeringLoadingIndicator)
    
    offeringLoadingIndicator.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
    }
    
    // The free trial text label
    freeTrialLabel = UILabel()
    freeTrialLabel.numberOfLines = 2
    freeTrialLabel.minimumScaleFactor = 0.01
    freeTrialLabel.textAlignment = .center
    freeTrialLabel.font = UIFont.systemFont(ofSize: 14)
    freeTrialLabel.textColor = textColor
    freeTrialLabel.alpha = 0.90
    freeTrialLabel.translatesAutoresizingMaskIntoConstraints = false
    stackViewContainer.addArrangedSubview(freeTrialLabel)
    
    // The restore button
    restoreButton = UIButton()
    restoreButton.addTarget(self, action: #selector(restorePurchases), for: .touchUpInside)
    restoreButton.translatesAutoresizingMaskIntoConstraints = false
    restoreButton.setTitle(Strings.restorePurchases, for: .normal)
    restoreButton.setTitleColor(textColor.withAlphaComponent(0.6), for: .normal)
    restoreButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
    restoreButton.isHidden = !allowRestore
    
    stackViewContainer.addArrangedSubview(restoreButton)
    
    restoreButton.snp.makeConstraints { (make) in
      make.height.equalTo(50)
    }
    
    // The Terms & Conditions Label
    termsAndConditionsLabel = UILabel()
    let tap = UITapGestureRecognizer(target: self, action: #selector(tapToCs(tap:)))
    termsAndConditionsLabel.addGestureRecognizer(tap)
    termsAndConditionsLabel.isUserInteractionEnabled = true
    termsAndConditionsLabel.numberOfLines = 2
    termsAndConditionsLabel.minimumScaleFactor = 0.01
    termsAndConditionsLabel.textAlignment = .center
    termsAndConditionsLabel.font = UIFont.systemFont(ofSize: 12)
    termsAndConditionsLabel.textColor = textColor
    termsAndConditionsLabel.alpha = 0.90
    

    let linkAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]
    let termsAndPrivacyStr = NSMutableAttributedString(string: "")
    let termsText = NSAttributedString(string: Strings.termsOfService, attributes: linkAttributes)
    let and = NSAttributedString(string: " \(Strings.and) ")
    let privacyText = NSAttributedString(string: Strings.privacyPolicy, attributes: linkAttributes)
    
    termsAndPrivacyStr.append(termsText)
    termsAndPrivacyStr.append(and)
    termsAndPrivacyStr.append(privacyText)
    termsAndConditionsLabel.attributedText = termsAndPrivacyStr
    
    termsAndConditionsLabel.translatesAutoresizingMaskIntoConstraints = false
    stackViewContainer.addArrangedSubview(termsAndConditionsLabel)
    
    termsAndConditionsLabel.snp.makeConstraints { (make) in
      make.height.equalTo(30)
    }
    
    // The close button
    closeButton = CloseButton(backgroundColor: productDeselectedColor, textColor: textColor)
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    view.addSubview(closeButton)
    
    closeButton.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.leading.equalTo(view.safeAreaLayoutGuide).inset(16)
      make.height.equalTo(40)
      make.width.equalTo(40)
    }
  }
}

extension SwiftPaywall: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return offering?.availablePackages.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let package = offering?.availablePackages[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PackageCell
    
    cell.didPurchasePackageSelected = self.didPurchasePackageSelected
    
    cell.setupWith(
      package: package,
      discount: shouldShowDiscount(package: package))
    
    // Should this package be selected
    if !didChangePackage && mostAffordablePackages.first?.product.productIdentifier == package?.product.productIdentifier {
      collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
      collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
      cell.isSelected = true
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    didChangePackage = true
    
    if #available(iOS 11.2, *) {
      if let introPrice = offering?.availablePackages[indexPath.row].product.introductoryPrice, introPrice.price == 0 {
        
        var trialLength = ""
        var cancelDate : Date?
        var cancelString = Strings.endOfTrail
        let numUnits = introPrice.subscriptionPeriod.numberOfUnits
        
        switch introPrice.subscriptionPeriod.unit {
        case .day:
          trialLength = "\(numUnits)-\(Strings.day.lowercased())"
          cancelDate = Calendar.current.date(byAdding: .day, value: numUnits-1, to: Date())
        case .week:
          trialLength = "\(numUnits*7)-\(Strings.day.lowercased())"
          cancelDate = Calendar.current.date(byAdding: .day, value: 7*numUnits-1, to: Date())
        case .month:
          trialLength = "\(numUnits)-\(Strings.month.lowercased())"
          cancelDate = Calendar.current.date(byAdding: .month, value: numUnits, to: Date())
          cancelDate = Calendar.current.date(byAdding: .day, value: -1, to: cancelDate ?? Date())
        case .year:
          trialLength = "\(numUnits)-\(Strings.year.lowercased())"
          cancelDate = Calendar.current.date(byAdding: .year, value: numUnits, to: Date())
          cancelDate = Calendar.current.date(byAdding: .day, value: -1, to: cancelDate ?? Date())
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        if let cancelDate = cancelDate {
          cancelString = dateFormatter.string(from: cancelDate)
        }
        
        let dateAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]
        let baseText = NSMutableAttributedString(string: "\(Strings.includes) \(trialLength) \(Strings.freeTrail) \(Strings.cancelBefore) ")
        let cancelAttributedText = NSAttributedString(string: cancelString, attributes: dateAttributes)
        let and = NSAttributedString(string: Strings.nothingWillBeBilled)
        
        baseText.append(cancelAttributedText)
        baseText.append(and)
        
        freeTrialLabel.attributedText = baseText
      } else {
        freeTrialLabel.text = nil
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.width, height: 64)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.bottom
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
  
}

private class PackageCell : UICollectionViewCell {
  
  var didPurchasePackageSelected: ((Purchases.Package) -> ())?
  
  let buyButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = UIColor.white
    button.setTitleColor(UIColor.darkText, for: .normal)
    button.layer.cornerRadius = 5
    button.titleLabel?.font = UIFont.appFontMedium(ofSize: 20)
    return button
  }()
  
  let discountLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 12)
    label.numberOfLines = 1
    label.minimumScaleFactor = 0.1
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = UIColor.white
    return label
  }()
  
  let discountFormatter = NumberFormatter()
  let priceFormatter = NumberFormatter()
  
  private var package: Purchases.Package?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    buildSubviews()
  }
  
  func setupWith(
    package: Purchases.Package?,
    discount: (Bool, Purchases.Package?)) {
    
    guard let package = package else {
      discountLabel.isHidden = true
      return
    }
    
    self.package = package
    
    discountLabel.isHidden = !discount.0
    var priceLabelText = ""
    var discountText = ""
    var monthlyPriceText = ""
    
    if discount.0, let discount = discount.1 {
      discountFormatter.numberStyle = .percent
      discountText = "\(Strings.save) \(discountFormatter.string(from: discountBetween(highest: discount, current: package)) ?? "")"
    }
    
    priceFormatter.numberStyle = .currency
    priceFormatter.locale = package.product.priceLocale
    
    switch package.packageType {
    case .lifetime:
      priceLabelText = package.localizedPriceString + " / " + Strings.lifeTime
      discountLabel.isHidden = true
    case .annual:
      priceLabelText = package.localizedPriceString + " / " + "1 " + Strings.year
      monthlyPriceText = "\(priceFormatter.string(from: package.product.price.dividing(by: 12.0)) ?? "") / \(Strings.monthShort)"
    case .sixMonth:
      priceLabelText = package.localizedPriceString + " / " + "6 " + Strings.months
      monthlyPriceText = "\(priceFormatter.string(from: package.product.price.dividing(by: 6.0)) ?? "") / \(Strings.monthShort)"
    case .threeMonth:
      priceLabelText = package.localizedPriceString + " / " + "3 " + Strings.months
      monthlyPriceText = "\(priceFormatter.string(from: package.product.price.dividing(by: 3.0)) ?? "") / \(Strings.monthShort)"
    case .twoMonth:
      priceLabelText = package.localizedPriceString + " / " + "2 " + Strings.months
      monthlyPriceText = "\(priceFormatter.string(from: package.product.price.dividing(by: 2.0)) ?? "") / \(Strings.monthShort)"
    case .monthly:
      priceLabelText = package.localizedPriceString + " / " + "1 " + Strings.month
      monthlyPriceText = "\(package.localizedPriceString) / \(Strings.monthShort)"
    case .weekly:
      priceLabelText = package.localizedPriceString + " / " + "1 " + Strings.week
      monthlyPriceText = "\(package.localizedPriceString) / \(Strings.weekShort)"
    case .custom, .unknown:
      priceLabelText = package.localizedPriceString + " / " + package.identifier.uppercased()
      discountLabel.isHidden = true
    }
    
    let discount = "(\(monthlyPriceText), \(discountText))"
    buyButton.setTitle(priceLabelText, for: .normal)
    discountLabel.text = discount
  }
  
  func discountBetween(highest: Purchases.Package, current: Purchases.Package) -> NSNumber {
    let highestAnnualCost : NSNumber!
    switch highest.packageType {
    case .annual:
      highestAnnualCost = highest.product.price
    case .sixMonth:
      highestAnnualCost = highest.product.price.multiplying(by: 2.0)
    case .threeMonth:
      highestAnnualCost = highest.product.price.multiplying(by: 4.0)
    case .twoMonth:
      highestAnnualCost = highest.product.price.multiplying(by: 6.0)
    case .monthly:
      highestAnnualCost = highest.product.price.multiplying(by: 12.0)
    case .weekly:
      highestAnnualCost = highest.product.price.multiplying(by: 52.0)
    case .lifetime, .custom, .unknown:
      return 0.0
    }
    
    let currentAnnualCost : NSNumber!
    switch current.packageType {
    case .annual:
      currentAnnualCost = current.product.price
    case .sixMonth:
      currentAnnualCost = current.product.price.multiplying(by: 2.0)
    case .threeMonth:
      currentAnnualCost = current.product.price.multiplying(by: 4.0)
    case .twoMonth:
      currentAnnualCost = current.product.price.multiplying(by: 6.0)
    case .monthly:
      currentAnnualCost = current.product.price.multiplying(by: 12.0)
    case .weekly:
      currentAnnualCost = current.product.price.multiplying(by: 52.0)
    case .lifetime, .custom, .unknown:
      return 0.0
    }
    
    return NSNumber(value: (highestAnnualCost.doubleValue - currentAnnualCost.doubleValue) / highestAnnualCost.doubleValue)
  }
  
  func buildSubviews() {
    addSubview(buyButton)
    addSubview(discountLabel)
    
    discountLabel.snp.makeConstraints { (make) in
      make.height.equalTo(20)
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
    
    buyButton.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalTo(discountLabel.snp.top)
    }
    
    buyButton.addTarget(self, action: #selector(handlePurchaseButtonClicked(button:)), for: .touchUpInside)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc func handlePurchaseButtonClicked(button: UIButton) {
    guard let package = self.package else { return }
    didPurchasePackageSelected?(package)
  }
}

fileprivate extension Purchases.Package {
  
  func annualCost() -> Double {
    switch self.packageType {
    case .annual:
      return self.product.price.doubleValue
    case .sixMonth:
      return self.product.price.doubleValue * 2
    case .threeMonth:
      return self.product.price.doubleValue * 4
    case .twoMonth:
      return self.product.price.doubleValue * 6
    case .monthly:
      return self.product.price.doubleValue * 12
    case .weekly:
      return self.product.price.doubleValue * 52
    case .lifetime, .custom, .unknown:
      return 0.0
    }
  }
}

private class CloseButton : UIButton {
  
  private struct Constants {
    static let plusLineWidth: CGFloat = 3.0
    static let plusButtonScale: CGFloat = 0.5
  }
  
  private var halfWidth: CGFloat {
    return bounds.width / 2
  }
  
  private var halfHeight: CGFloat {
    return bounds.height / 2
  }
  
  private var bgColor : UIColor
  private var txtColor : UIColor
  
  init(backgroundColor: UIColor, textColor: UIColor) {
    
    bgColor = backgroundColor
    txtColor = textColor
    
    super.init(frame: .zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ rect: CGRect) {
    let path = UIBezierPath(ovalIn: rect)
    bgColor.withAlphaComponent(0.1).setFill()
    path.fill()
    
    //set up the width and height variables
    //for the horizontal stroke
    let plusWidth: CGFloat = min(bounds.width, bounds.height) * Constants.plusButtonScale
    let halfPlusWidth = (plusWidth / 2) / sqrt(2)
    
    //create the plus
    let plusPath = UIBezierPath()
    
    //move the initial point of the path
    //to the start of the horizontal stroke
    plusPath.move(to: CGPoint(
      x: halfWidth - halfPlusWidth,
      y: halfHeight - halfPlusWidth))
    
    //add a point to the path at the end of the stroke
    plusPath.addLine(to: CGPoint(
      x: halfWidth + halfPlusWidth,
      y: halfHeight + halfPlusWidth))
    
    //move the initial point of the path
    //to the start of the vertical stroke
    plusPath.move(to: CGPoint(
      x: halfWidth - halfPlusWidth,
      y: halfHeight + halfPlusWidth))
    
    //add a point to the path at the end of the stroke
    plusPath.addLine(to: CGPoint(
      x: halfWidth + halfPlusWidth,
      y: halfHeight - halfPlusWidth))
    
    //set the stroke color
    txtColor.withAlphaComponent(0.5).setStroke()
    
    //set the details
    plusPath.lineCapStyle = .round
    plusPath.lineWidth = Constants.plusLineWidth
    
    //draw the stroke
    plusPath.stroke()
  }
}

import WebKit
private class WebViewController: UIViewController {
  
  var url : URL
  var webView : WKWebView!
  var textColor : UIColor?
  var barColor : UIColor?
  
  init(url: URL, title: String?, textColor: UIColor?, barColor: UIColor?) {
    self.url = url
    self.textColor = textColor
    self.barColor = barColor
    super.init(nibName: nil, bundle: nil)
    
    self.title = title
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView = WKWebView(frame: view.frame, configuration: WKWebViewConfiguration())
    webView.load(URLRequest(url: url))
    view.addSubview(webView)
    
    // reconfig the navigation bar
    navigationController?.navigationBar.tintColor = textColor
    navigationController?.navigationBar.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor : textColor ?? .black
    ]
    navigationController?.navigationBar.barTintColor = barColor
    navigationController?.navigationBar.isTranslucent = false
    UINavigationBar.appearance().shadowImage = UIImage()
    
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(close))
    
  }
  
  @objc func close() {
    dismiss(animated: true, completion: nil)
  }
}


fileprivate extension UITapGestureRecognizer {
  
  func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
    // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    let layoutManager = NSLayoutManager()
    let textContainer = NSTextContainer(size: CGSize.zero)
    let textStorage = NSTextStorage(attributedString: label.attributedText ?? NSAttributedString(string: ""))
    
    // Configure layoutManager and textStorage
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    
    // Configure textContainer
    textContainer.lineFragmentPadding = 0.0
    textContainer.lineBreakMode = label.lineBreakMode
    textContainer.maximumNumberOfLines = label.numberOfLines
    let labelSize = label.bounds.size
    textContainer.size = labelSize
    
    // Find the tapped character location and compare it to the specified range
    let locationOfTouchInLabel = self.location(in: label)
    let textBoundingBox = layoutManager.usedRect(for: textContainer)
    
    let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
    
    let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
    let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
    return NSLocationInRange(indexOfCharacter, targetRange)
  }
}
