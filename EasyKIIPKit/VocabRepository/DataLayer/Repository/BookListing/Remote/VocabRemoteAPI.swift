//
//  VocabRemoteAPI.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

protocol VocabRemoteAPI {
  func loadPracticeHistory(completion: @escaping ([PracticeHistory])->(Void))
}
