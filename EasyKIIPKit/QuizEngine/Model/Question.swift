//
//  Question.swift
//  EasyKIIPKit
//
//  Created by Tuan on 2020/06/06.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public enum Question: Equatable, Hashable {
  case newWord(NewWordQuestion)
  case practice(PracticeQuestion)
}