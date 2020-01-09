//
//  CropViewController.swift
//  ViedoMaker
//
//  Created by Mohammed Khaled on 1/8/20.
//  Copyright © 2020 Ibtikar. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AVKit
import Photos
import MediaPlayer

class CropViewController: UIViewController {

    @IBOutlet private weak var videoFramesView: UIView!
    @IBOutlet private weak var frameContainerView: UIView!
    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var endTimeLabel: UILabel!
    
    var videoUrl: URL?
    var videoTotalSeconds = 0.0
    var rangeSlider: RangeSlider! = nil
    var isSliderEnd = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let url = videoUrl {
            self.createImageFramesforCrop(strUrl: url)
            setVideoDuration(url)
        }
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
    
    func setVideoDuration(_ url: URL) {
        let asset = AVAsset(url: url)
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        self.videoTotalSeconds = durationTime
        fillData()
    }
    
    @IBAction func cancelCrop(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func applyCrop(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension CropViewController {
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
        
        let thumbAvg = thumbtimeSeconds/6
        var startTime = 1
        var startXPosition: CGFloat = 0.0
        
        //loop for 6 number of frames
        for _ in 0...5
        {
            
            let imageButton = UIButton()
            let xPositionForEach = CGFloat(self.videoFramesView.frame.width)/6
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
}

extension CropViewController {
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
//        if(rangeSlider.lowerLayerSelected)
//        {
//            self.seekVideo(toPos: CGFloat(rangeSlider.lowerValue))
//
//        }
//        else
//        {
//            self.seekVideo(toPos: CGFloat(rangeSlider.upperValue))
//
//        }
        
    }
    
    //Seek video when slide
//    func seekVideo(toPos pos: CGFloat) {
//        self.videoPlaybackPosition = pos
//        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), preferredTimescale: self.player.currentTime().timescale)
//        self.player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
//
//        if(pos == CGFloat(thumbtimeSeconds))
//        {
//            self.player.pause()
//        }
//    }
}
