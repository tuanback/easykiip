//
//  SpeedSynthesizer.swift
//  EasyKIIP
//
//  Created by Tuan on 2020/07/11.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import AVFoundation
import Foundation

class SpeechSynthesizer: NSObject {
  
  private let synthesizer = AVSpeechSynthesizer()
  
  func speak(word: String) {
    guard !synthesizer.isSpeaking else {
      return
    }
    configAudioSession()
    
    let utterance = AVSpeechUtterance(string: word)
    utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
    synthesizer.speak(utterance)
    synthesizer.delegate = self
  }
  
  private func configAudioSession() {
    let audioSession = AVAudioSession.sharedInstance()
    try? audioSession.setActive(false)
    try? audioSession.setCategory(.playback)
  }
  
}

extension SpeechSynthesizer: AVSpeechSynthesizerDelegate {
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    
  }
  
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    
  }
}
