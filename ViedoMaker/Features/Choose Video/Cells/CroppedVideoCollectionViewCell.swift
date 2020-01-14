//
//  CroppedVideoCollectionViewCell.swift
//  ViedoMaker
//
//  Created by Mahmoud Nasser on 1/9/20.
//  Copyright © 2020 Ibtikar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos
import MediaPlayer
import Presentr
import MobileCoreServices


class CroppedVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak  var audioRecordingView: AudioRecorderView!

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var avplayer = AVPlayer()
    var playerController = AVPlayerViewController()
    var audioUrl: URL?
    var videoUrl: URL? {
        didSet {
            if let videoUrl = videoUrl{
                addVideo(videoUrl: videoUrl)
                setupCell()
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAudioRecorder()
        // Initialization code
    }
    
    func setupAudioRecorder() {
        audioRecordingView.setupView()
        audioRecordingView.delegate = self
    }
    
    //MARK: add Video to View
     private func addVideo(videoUrl: URL) {
        self.avplayer = AVPlayer(url: videoUrl)
        playerController.player = self.avplayer
        self.view.addSubview(playerController.view)
        playerController.view.frame = self.view.bounds
        playerController.showsPlaybackControls = true
    }
    
    private func setupCell() {
       // audioImageView.image = UIImage(named: "ic_record")
    }

}

extension CroppedVideoCollectionViewCell: AudioRecorderDelegate {
    func audioRecordingFinished(_ url: URL) {
        self.audioUrl = url
    }
}

extension CroppedVideoCollectionViewCell {
    @IBAction func mergeAudioWithVideo() {
        let videoEditor = VideoEditor()
        if let videoUrl = videoUrl, let audioUrl = audioUrl {
            videoEditor.mergeVideoWithAudio(videoUrl: videoUrl, audioUrl: audioUrl, success: { (url) in
                DispatchQueue.main.async {
                    self.saveToCameraRoll(URL: url as NSURL)
                    self.addVideoPlayer(videoUrl: url, to: self.videoPlayerView)
                }
            }) { (error) in
                
            }
        }
    }
    
}
