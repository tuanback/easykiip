//
//  TutorialItemVC.swift
//  TutorialTemplate
//
//  Created by Tuan on 2019/12/27.
//  Copyright © 2019 3i. All rights reserved.
//

import UIKit
import AVFoundation

class TutorialItemVC: UIViewController {
  
  static func storyboardInstance(videoURL: URL, heading: String, message: String) -> TutorialItemVC? {
    if let vc = UIStoryboard(name: String(describing: TutorialItemVC.self), bundle: nil).instantiateInitialViewController() as? TutorialItemVC {
      vc.videoURL     = videoURL
      vc.headingText  = heading
      vc.messageText  = message
      return vc
    }
    return nil
  }
  
  @IBOutlet weak var viewVideoContainer: UIView!
  @IBOutlet weak var textHeading: UILabel!
  @IBOutlet weak var textMessage: UILabel!
  
  private var videoURL: URL!
  private var headingText: String!
  private var messageText: String!
  
  private var playerLayer: AVPlayerLayer!
  private var player: AVPlayer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupViews()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    endDisplaying()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    updatePlayerLayerFrame()
  }
  
  private func setupViews() {
    textHeading.text = headingText
    textMessage.text = messageText
    setupPlayerView(url: videoURL)
  }
  
}

extension TutorialItemVC {
  private func getPlayerLayerFrame() -> CGRect {
    let videoContainerWidth = viewVideoContainer?.frame.width ?? 0
    let videoContainerHeight = viewVideoContainer?.frame.height ?? 0
    
    let playerSize = min(videoContainerWidth, videoContainerHeight)
    let point = CGPoint(x: (videoContainerWidth - playerSize) / 2, y: (videoContainerHeight - playerSize) / 2)
    return CGRect(origin: point, size: CGSize(width: playerSize, height: playerSize))
  }
  
  private func updatePlayerLayerFrame() {
    guard playerLayer != nil else { return }
    playerLayer?.frame = getPlayerLayerFrame()
  }
  
  private func setupPlayerView(url: URL) {
    
    try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
    try? AVAudioSession.sharedInstance().setActive(true)
    
    player = AVPlayer(url: url)
    player?.volume = 1.0
    
    playerLayer = AVPlayerLayer(player: player)
    viewVideoContainer.layer.addSublayer(playerLayer)
    playerLayer?.frame = getPlayerLayerFrame()
    
    player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
    
    //track player progress
    
    let interval = CMTime(value: 1, timescale: 2)
    player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] (progressTime) in
      
      let seconds = CMTimeGetSeconds(progressTime)
      guard let duration = self?.player?.currentItem?.duration else {
        return
      }
      
      let durationSeconds = CMTimeGetSeconds(duration)
      
      if seconds >= durationSeconds {
        // Seek and play again
        self?.player?.seek(to: CMTime.zero, completionHandler: { (completedSeek) in
          //perhaps do something later here
          self?.player?.play()
        })
      }
    })
  }
  
  func endDisplaying() {
    stopVideoPlaying()
    removeVideoLayer()
  }
  
  func stopVideoPlaying() {
    player?.removeObserver(self, forKeyPath: "currentItem.loadedTimeRanges", context: nil)
    player?.pause()
    player?.replaceCurrentItem(with: nil)
    player = nil
  }
  
  func removeVideoLayer() {
    playerLayer?.removeFromSuperlayer()
    playerLayer = nil
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard player != nil else { return }
    
    //this is when the player is ready and rendering frames
    if keyPath == "currentItem.loadedTimeRanges" {
      // It crashed once, please check when it happens again
      DispatchQueue.main.async {
        self.updatePlayerLayerFrame()
      }
      
      player?.play()
    }
  }
}
