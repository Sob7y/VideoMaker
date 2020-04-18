//
//  CropOriginalViewController.swift
//  ViedoMaker
//
//  Created by Mahmoud Nasser on 4/11/20.
//  Copyright © 2020 Ibtikar. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AVKit
import Photos
import MediaPlayer
import Presentr

class CropOriginalViewController: UIViewController {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var videoPlayerView: UIView!
    @IBOutlet private weak var resultPlayerView: UIView!
    @IBOutlet private weak var videoCroppingContainerView: UIView!
    @IBOutlet private weak var videoFramesView: UIView!
    @IBOutlet private weak var frameContainerView: UIView!
    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var endTimeLabel: UILabel!
    
    
    var videoPicker: VideoPicker!
    var playerController1 = AVPlayerViewController()
    var playerController2 = AVPlayerViewController()
    var avplayer1 = AVPlayer()
    var avplayer2 = AVPlayer()
    var videoUrl: URL?
    var thumbTime: CMTime!
    var thumbtimeSeconds: Int!
    var videoPlaybackPosition: CGFloat = 0.0
    var asset: AVAsset!
    var videoTotalSeconds = 0.0
    var rangeSlider: RangeSlider! = nil
    var isSliderEnd = true
    let videoModel = VideoModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeAllOutputFiles(folder: "output")
        removeAllOutputFiles(folder: "MergedVideos")
        self.view.backgroundColor = .darkGray
        containerView.backgroundColor = .darkGray
    }
    
}

//IBActions
extension CropOriginalViewController {
    @IBAction func videoPickerButtonTouched(_ sender: UIButton) {
        self.videoPicker = VideoPicker(presentationController: self, delegate: self)
        self.videoPicker.present(from: sender)
    }
    
    @IBAction func applyCrop(_ sender: UIButton) {
        removeOutputCroppedFile()
        
       let start = self.rangeSlider.lowerValue
        let end = self.rangeSlider.upperValue
        
//        let start = Float(startTimeLabel.text!)
//        let end = Float(endTimeLabel.text!)
        
        self.cropVideo(sourceURL1: videoUrl!, startTime: Float(start), endTime: Float(end))
    }
    
    private func removeOutputCroppedFile() {
        let manager = FileManager.default
        guard let documentDirectory = try? manager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true) else {return}
        let outputURL = documentDirectory.appendingPathComponent("output/cropped.mp4")
        _ = try? manager.removeItem(at: outputURL)
    }
    
    private func removeAllOutputFiles(folder: String) {
        let manager = FileManager.default
        guard let documentDirectory = try? manager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true) else {return}
        let outputURL = documentDirectory.appendingPathComponent(folder)
        _ = try? manager.removeItem(at: outputURL)
    }
    
    @IBAction func cropButtonTapped(_ sender: Any) {
        let videoCreateVC = Container.Controllers.createVideoCreatorViewController(url: videoModel.oroginalPath)
        self.navigationController?.pushViewController(videoCreateVC, animated: true)
        }
}


extension CropOriginalViewController: VideoPickerDelegate {
    
    func didSelect(url: URL?) {
        guard let url = url else {
            return
        }

        self.videoUrl = url
        self.addOriginalVideoPlayer(videoUrl: url, to: self.videoPlayerView)
        self.videoCroppingContainerView.isHidden = false
        if let url = videoUrl {
            asset = AVURLAsset.init(url: url as URL)
            self.createImageFramesforCrop(strUrl: url)
            setVideoDuration(url)
        }
    }
    
    //MARK: Video Play Action
    func addOriginalVideoPlayer(videoUrl: URL, to view: UIView) {
        self.avplayer1 = AVPlayer(url: videoUrl)
        playerController1.player = self.avplayer1
        self.addChild(playerController1)
        view.addSubview(playerController1.view)
        playerController1.view.frame = view.bounds
        playerController1.showsPlaybackControls = true
        self.avplayer1.play()
    }
    
    func addCroppedVideoPlayer(videoUrl: URL, to view: UIView) {
        self.avplayer2 = AVPlayer(url: videoUrl)
        playerController2.player = self.avplayer2
        self.addChild(playerController2)
        view.addSubview(playerController2.view)
        playerController2.view.frame = view.bounds
        playerController2.showsPlaybackControls = true
        self.avplayer2.play()
    }
    
    
    func setVideoDuration(_ url: URL) {
        let asset = AVAsset(url: url)
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        self.videoTotalSeconds = durationTime
        fillData()
    }
    
    private func fillData() {
        if videoTotalSeconds < 60 {
            startTimeLabel.text = "\(0.0)s"
            endTimeLabel.text = String(format: "%.2fs",(videoTotalSeconds))
        } else {
            startTimeLabel.text = "\(0.0)m"
            endTimeLabel.text = String(format: "%.2fm",(videoTotalSeconds/60))
        }
    }
}

extension CropOriginalViewController {
    //MARK: Create video Image Frames
    func createImageFramesforCrop(strUrl : URL) {
        
        //Avsset creation
        let asset = AVAsset(url: strUrl)
        
        //creating assets
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = CMTime.zero
        assetImgGenerate.requestedTimeToleranceBefore = CMTime.zero
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        let thumbTime: CMTime = asset.duration
        let thumbtimeSeconds = Int(CMTimeGetSeconds(thumbTime))
        let maxLength = "\(thumbtimeSeconds)" as NSString
        
        let thumbAvg = thumbtimeSeconds/10
        var startTime = 1
        var startXPosition: CGFloat = 0.0
        
        //loop for 6 number of frames
        for _ in 0...9
        {
            
            let imageButton = UIButton()
            let xPositionForEach = CGFloat(self.videoFramesView.frame.width)/10
            imageButton.frame = CGRect(
                x: CGFloat(startXPosition),
                y: CGFloat(0),
                width: xPositionForEach,
                height: CGFloat(self.videoFramesView.frame.height))
            do {
                let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: img)
                imageButton.setImage(image, for: .normal)
            }
            catch _ as NSError
            {
            }
            
            startXPosition = startXPosition + xPositionForEach
            startTime = startTime + thumbAvg
            imageButton.isUserInteractionEnabled = false
            self.videoFramesView.addSubview(imageButton)
        }
        createRangeSlider()
    }
    
    //Create range slider
    func createRangeSlider() {
        //Remove slider if already present
        let subViews = self.frameContainerView.subviews
        for subview in subViews{
            if subview.tag == 1000 {
                subview.removeFromSuperview()
            }
        }
        
        rangeSlider = RangeSlider(frame: frameContainerView.bounds)
        frameContainerView.addSubview(rangeSlider)
        rangeSlider.tag = 1000
        
        //Range slider action
        rangeSlider.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)
        
        let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.rangeSlider.trackHighlightTintColor = UIColor.clear
            self.rangeSlider.curvaceousness = 1.0
        }
        
    }
    
    //MARK: rangeSlider Delegate
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        //        self.player.pause()
        
        if(isSliderEnd == true)
        {
            rangeSlider.minimumValue = 0.0
            rangeSlider.maximumValue = Double(videoTotalSeconds)
            
            rangeSlider.upperValue = Double(videoTotalSeconds)
            isSliderEnd = !isSliderEnd
            
        }
        
        startTimeLabel.text = "\(rangeSlider.lowerValue)"
        endTimeLabel.text   = "\(rangeSlider.upperValue)"
        
        print(rangeSlider.lowerLayerSelected)
        if(rangeSlider.lowerLayerSelected) {
            self.seekVideo(toPos: CGFloat(rangeSlider.lowerValue))
        } else {
            self.seekVideo(toPos: CGFloat(rangeSlider.upperValue))
        }
    }
    
    //Seek video when slide
    func seekVideo(toPos pos: CGFloat) {
        self.videoPlaybackPosition = pos
        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), preferredTimescale: self.avplayer1.currentTime().timescale)
        self.avplayer1.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        if(pos == CGFloat(videoTotalSeconds)) {
            self.avplayer1.pause()
        }
    }
}

extension CropOriginalViewController {
    //Trim Video Function
    func cropVideo(sourceURL1: URL, startTime:Float, endTime:Float) {
        
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {return}
        guard let mediaType = "mp4" as? String else {return}
        guard (sourceURL1 as? URL) != nil else {return}
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String
        {
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            print("video length: \(length) seconds")
            
            let start = startTime
            let end = endTime
            
            videoModel.startTime = start
            videoModel.endTime = end
            print(documentDirectory)
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                //let name = hostent.newName()
                outputURL = outputURL.appendingPathComponent("cropped.mp4")
                videoModel.oroginalPath = outputURL
                                
            }catch let error {
                print(error)
            }
            
            //Remove existing file
            //   _ = try? manager.removeItem(at: outputURL)
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = videoModel.oroginalPath
            exportSession.outputFileType = AVFileType.mp4
            
            let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    print("exported at \(outputURL)")
                    
                    DispatchQueue.main.async {
                         self.addCroppedVideoPlayer(videoUrl: outputURL, to: self.resultPlayerView)
                    }
                   
                //         self.saveToCameraRoll(URL: outputURL as NSURL?)
                case .failed:
                    print("failed \(String(describing: exportSession.error))")
                    
                case .cancelled:
                    print("cancelled \(String(describing: exportSession.error))")
                    
                default: break
                }
            }
        }
    }
    
    //Save Video to Photos Library
    func saveToCameraRoll(URL: NSURL!) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL as URL)
        }) { saved, error in
            if saved {
                let alertController = UIAlertController(title: "Cropped video was successfully saved", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

