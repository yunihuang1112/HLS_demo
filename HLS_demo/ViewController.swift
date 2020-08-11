//
//  ViewController.swift
//  HLS_demo
//
//  Created by YUNI on 2020/8/11.
//  Copyright © 2020 YUNI. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var slider: UISlider!
    
    private let m3u8Url = "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8"
    private var videoPlayer: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        slider.isHidden = true
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer, player == videoPlayer, keyPath == "status" {
            if player.status == .readyToPlay {
                videoPlayer?.play()
            } else if player.status == .failed {
                stopBtnPressed(UIButton())
            }
        }
    }

    @IBAction func playBtnPressed(_ sender: Any) {
        if let videoPlayer = videoPlayer {
            videoPlayer.play()
        } else {
            startPlayer()
        }
    }
    
    @IBAction func pauseBtnPressed(_ sender: Any) {
        videoPlayer?.pause()
    }
    
    @IBAction func stopBtnPressed(_ sender: Any) {
        videoPlayer?.pause()
        videoPlayer = nil
        
        playerView.layer.sublayers?
            .filter { $0 is AVPlayerLayer }
            .forEach { $0.removeFromSuperlayer() }
        playerView.backgroundColor = .black
        self.title = ""
    }
    
    @IBAction func replayBtnPressed(_ sender: Any) {
        stopBtnPressed(UIButton())
        startPlayer()
    }
    
    @IBAction func sliderTouchUp(_ sender: Any) {
        videoPlayer?.pause()
        let value = slider.value
        // seek the seconds for video
        videoPlayer?.currentItem?.seek(to: CMTime(seconds: Double(value), preferredTimescale: 60000), completionHandler: { [weak self] (success) in
            self?.videoPlayer?.play()
        })
    }
    
    private func initSlider() {
        if let videoPlayer = videoPlayer {
            slider.minimumValue = 0.0
            if let duration = videoPlayer.currentItem?.asset.duration {
                let seconds = CMTimeGetSeconds(duration)
                slider.maximumValue = Float(seconds)
                slider.isHidden = false
            }
        } else {
            slider.isHidden = true
        }
    }
    
    private func startPlayer() {
        slider.isHidden = true
        if let url = URL(string: m3u8Url) {
            let asset = AVURLAsset(url: url, options: nil)
            let playerItem = AVPlayerItem(asset: asset)
            videoPlayer = AVPlayer(playerItem: playerItem)
            videoPlayer?.addObserver(self, forKeyPath: "status", options: [], context: nil)
            // listen the current time of playing video
            videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: Double(1), preferredTimescale: 2), queue: DispatchQueue.main) { [weak self] (sec) in
                guard let self = self else { return }
                let seconds = CMTimeGetSeconds(sec)
                let (hours, minutes, second) = self.getHoursMinutesSecondsFrom(seconds: seconds)
                self.title = "\(hours):\(minutes):\(second)"
                self.slider.value = Float(seconds)
            }
            videoPlayer?.volume = 1.0
            
            let layer: AVPlayerLayer = AVPlayerLayer(player: videoPlayer)
            layer.backgroundColor = UIColor.white.cgColor
            layer.frame = playerView.bounds
            layer.videoGravity = .resizeAspectFill
            playerView.layer.sublayers?
                .filter { $0 is AVPlayerLayer }
                .forEach { $0.removeFromSuperlayer() }
            playerView.layer.addSublayer(layer)
        }
        initSlider()
    }
    
    private func getHoursMinutesSecondsFrom(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
}

