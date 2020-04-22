//
//  ProficiencyCalculator.swift
//  EasyKIIP
//
//  Created by Real Life Swift on 2020/04/21.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

struct ProficiencyCalculator {
  
  /// Calculate vocab proficiency
  /// - Parameter vocab: vocab that needs to be calculated for proficiency
  /// - Returns: Proficiency in range of 0 - 100
  static func calculate(vocab: Vocab) -> UInt8 {
    if vocab.practiceHistory.isMastered {
      return 100
    }
    
    if !vocab.practiceHistory.isLearned {
      return 0
    }
    
    // Need to think about the decay algorithm to declare more reasonable test
    // Note: Need a functions that recommend user to review the vocabs after 1 days, one week, one month
    /*
    - Look at the words again after 24 hours, after one week and after one month.
    - Read, read, read. The more times you ‘see’ a word the more easily you will remember it.
    - Use the new words. You need to use a new word about ten times before you remember it!
    - Do word puzzles and games like crosswords, anagrams and wordsearches.
    - Make word cards and take them with you. Read them on the bus or when you are waiting for your friends.
    - Learn words with a friend. It can be more fun and easier to learn with someone else.
     
     Ideas:
     // Decay rate is when user don't review a vocab for several days
     // Note: Everytime user takes the test, one vocab if appear will most likely appear for 2 - 5 times
     - If the vocab is reviewed today => Proficiency set to 100 %
     - Test taken (correct answer):
     - 1 - 6: Decay rate 49% per day
     - 7 - 12: Decay rate 36% per day
     - 13 - 18: Decay rate 25% per day
     - 19 - 24: Decay rate 16% per day
     - 25 - 30: Decay rate 9% per day
     - 31 - 36: Decay rate 4% per day
     - 37 - 42: Decay rate 1% per day
    */
    return 100
  }
}
