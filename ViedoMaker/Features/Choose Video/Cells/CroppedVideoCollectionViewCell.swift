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

protocol UpdateVideoUrlDelegate: class {
    func updateVideoUrl(url: URL, index: Int)
}

class CroppedVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var view: UIView!
    @IBOutlet private weak  var audioRecordingView: AudioRecorderView!

    weak var delegate: UpdateVideoUrlDelegate?
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var asset: AVAsset!
    var index: Int?
    var avplayer = AVPlayer()
    var playerController = AVPlayerViewController()
    var audioUrl: URL?
    var videoUrl: URL? {
        didSet {
            if let videoUrl = videoUrl{
                asset = AVURLAsset.init(url: videoUrl as URL)
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
                    self.videoUrl = url
                    if let index = self.index {
                        self.delegate?.updateVideoUrl(url: url, index: index)
                    }
                  //  self.saveToCameraRoll(URL: url as NSURL)
                    self.exportVideo(outputURL: videoUrl)
                    //self.addVideoPlayer(videoUrl: url, to: self.videoPlayerView)
                    self.addVideo(videoUrl: videoUrl)
                }
            }) { (error) in
                
            }
        }
    }
    
    private func exportVideo(outputURL: URL) {
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        
         exportSession.exportAsynchronously{
             switch exportSession.status {
             case .completed:
                 print("exported at \(outputURL)")

        //         self.saveToCameraRoll(URL: outputURL as NSURL?)
             case .failed:
                 print("failed \(exportSession.error)")
                 
             case .cancelled:
                 print("cancelled \(exportSession.error)")
                 
             default: break
             }
         }
    }
    
}
