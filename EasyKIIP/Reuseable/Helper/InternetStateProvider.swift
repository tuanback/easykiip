//
//  InternetStateProvider.swift
//  PivoMeet
//
//  Created by Tuan on 2020/04/29.
//  Copyright © 2020 3i. All rights reserved.
//

import Foundation
import Reachability
import RxSwift
import RxCocoa

class InternetStateProvider {
  
  static let shared = InternetStateProvider()
  
  static var isInternetConnected = false
  static var connectionType: Reachability.Connection {
    InternetStateProvider.shared.getConnectionType()
  }
  
  public lazy var oInternetConnectionState = rConnectionState.asObservable()
  private var rConnectionState = BehaviorRelay<Bool>(value: true)
  
  private let reachability: Reachability
  
  public func startListen() {
    do {
      try reachability.startNotifier()
    }
    catch {
      print("Unable to start notifier")
    }
  }
  
  public func stopListen() {
    reachability.stopNotifier()
  }
  
  private init() {
    reachability = try! Reachability()
    setupReachAbility()
  }
  
  private func setupReachAbility() {
    reachability.whenReachable = { [weak self] reachability in
      InternetStateProvider.isInternetConnected = true
      self?.rConnectionState.accept(true)
    }
    
    reachability.whenUnreachable = { [weak self] _ in
      InternetStateProvider.isInternetConnected = false
      self?.rConnectionState.accept(false)
    }
  }
  
  private func getConnectionType() -> Reachability.Connection {
    reachability.connection
  }
  
}
