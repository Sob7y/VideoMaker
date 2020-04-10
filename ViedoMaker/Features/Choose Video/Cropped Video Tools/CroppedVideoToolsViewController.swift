//
//  CroppedVideoToolsViewController.swift
//  ViedoMaker
//
//  Created by Mahmoud Nasser on 4/10/20.
//  Copyright © 2020 Ibtikar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos
import MediaPlayer
import Presentr
import MobileCoreServices

protocol CroppedVideoDelegate: class {
    func croppedVideoMerged()
}

class CroppedVideoToolsViewController: UIViewController {
    
    @IBOutlet private weak var vPlayerContainerview: UIView!
    @IBOutlet private weak var editedVPlayerContainerview: UIView!
    @IBOutlet private weak  var audioRecordingView: AudioRecorderView!
    
    weak var delegate: CroppedVideoDelegate?
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var asset: AVAsset!
    var index: Int?
    var audioUrl: URL?
    var videoUrl: URL?
    var originalAvplayer = AVPlayer()
    var originalPlayerController = AVPlayerViewController()
    var editedAvplayer = AVPlayer()
    var editedPlayerController = AVPlayerViewController()
    var videoModel: VideoModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let videoUrl = videoModel?.oroginalPath {
            asset = AVURLAsset.init(url: videoUrl as URL)
            addVideoToOriginalView(videoUrl: videoUrl)
            setupCell()
            setupAudioRecorder()
        }
    }
    
    func setupAudioRecorder() {
        audioRecordingView.index = index
        audioRecordingView.setupView()
        audioRecordingView.delegate = self
        
    }
    

    //MARK: add Video to View
    private func addVideoToOriginalView(videoUrl: URL) {
        originalAvplayer = AVPlayer(url: videoUrl)
        originalPlayerController.player = originalAvplayer
        self.vPlayerContainerview.addSubview(originalPlayerController.view)
        originalPlayerController.view.frame = self.vPlayerContainerview.bounds
        originalPlayerController.showsPlaybackControls = true
    }
    
    private func addVideoToEditedView(videoUrl: URL) {
        originalAvplayer = AVPlayer(url: videoUrl)
        editedPlayerController.player = originalAvplayer
        self.editedVPlayerContainerview.addSubview(editedPlayerController.view)
        editedPlayerController.view.frame = self.editedVPlayerContainerview.bounds
        editedPlayerController.showsPlaybackControls = true
    }
    
    private func setupCell() {
        // audioImageView.image = UIImage(named: "ic_record")
    }
    
    @IBAction func MergeButtonTapped(_ sender: Any) {
        delegate?.croppedVideoMerged()
        dismiss(animated: true, completion: nil)
    }
}




extension CroppedVideoToolsViewController: AudioRecorderDelegate {
    func audioRecordingFinished(_ url: URL) {
            self.videoModel?.audioPath = url
    }
    

}

extension CroppedVideoToolsViewController {
    @IBAction func mergeAudioWithVideo() {
        let videoEditor = VideoEditor()
        if let videoUrl = videoModel?.oroginalPath, let audioUrl = videoModel?.audioPath {
            videoEditor.mergeVideoWithAudio(videoUrl: videoUrl, audioUrl: audioUrl, success: { (url) in
                DispatchQueue.main.async {
                    self.videoModel?.editedPath = url
//                    if let index = self.index {

//                        //  self.removeFile(at: audioUrl)
                    //  self.saveToCameraRoll(URL: url as NSURL)
                    if let videoUrl = self.videoModel?.editedPath {
                        
                        self.exportVideo(outputURL: videoUrl)
                        self.addVideoToEditedView(videoUrl: videoUrl)
                    }
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
    //    private func removeFile(at url: URL) {
    //        let manager = FileManager.default
    //        if let audioUrl = audioUrl {
    //            _ = try? manager.removeItem(at: audioUrl)
    //        }
    //    }
    
}
