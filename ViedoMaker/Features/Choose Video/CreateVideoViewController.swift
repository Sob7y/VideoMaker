//
//  CreateVideoViewController.swift
//  ViedoMaker
//
//  Created by Mohammed Khaled on 1/7/20.
//  Copyright © 2020 Ibtikar. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AVKit
import Photos
import MediaPlayer
import Presentr

class CreateVideoViewController: UIViewController {
    
    var videoPicker: VideoPicker!
    var playerController = AVPlayerViewController()
    var avplayer = AVPlayer()
    var videoUrl: URL?
    var thumbTime: CMTime!
    var thumbtimeSeconds: Int!
    var videoPlaybackPosition: CGFloat = 0.0
    var asset: AVAsset!
    var numberOfCroppedVideos = 0
    
    var croppedVideos: [VideoModel] = []
    
    //  @IBOutlet weak var videoView: VideoView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var videoPlayerView: UIView!
    @IBOutlet private weak var videoPickerButton: UIButton!
    @IBOutlet private weak var videoCroppingContainerView: UIView!
    @IBOutlet private weak var videoFramesView: UIView!
    @IBOutlet private weak var frameContainerView: UIView!
    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var endTimeLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var croppedCollectionViewHeightConstrain: NSLayoutConstraint!
    @IBOutlet private weak var scrollSubView: UIView!
    
    var videoTotalSeconds = 0.0
    var rangeSlider: RangeSlider! = nil
    var isSliderEnd = true
    
    let presentr: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.transitionType = nil
        presenter.dismissTransitionType = nil
        presenter.keyboardTranslationType = .moveUp
        presenter.dismissOnSwipe = true
        presenter.presentationType = .bottomHalf
        return presenter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCollectionViewCells()
        self.view.backgroundColor = .darkGray
        containerView.backgroundColor = .darkGray
        scrollSubView.backgroundColor = .darkGray
        collectionView.backgroundColor = .darkGray
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {return}
        let outputURL = documentDirectory.appendingPathComponent("output")
        _ = try? manager.removeItem(at: outputURL)
    }
    
    private func registerCollectionViewCells() {
        self.collectionView.register(
            UINib(nibName: "CroppedVideoCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "CroppedVideoCollectionViewCell")
    }
}

//IBActions
extension CreateVideoViewController {
    @IBAction func videoPickerButtonTouched(_ sender: UIButton) {
        self.videoPicker = VideoPicker(presentationController: self, delegate: self)
        self.videoPicker.present(from: sender)
    }
    
    
    @IBAction func cancelCrop(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func applyCrop(_ sender: UIButton) {
        let start = Float(startTimeLabel.text!)
        let end = Float(endTimeLabel.text!)
        self.cropVideo(sourceURL1: videoUrl!, startTime: start!, endTime: end!)
    }
}

extension CreateVideoViewController: VideoPickerDelegate {
    
    func didSelect(url: URL?) {
        guard let url = url else {
            return
        }

        self.videoUrl = url
        self.addVideoPlayer(videoUrl: url, to: self.videoPlayerView)
        self.videoCroppingContainerView.isHidden = false
        if let url = videoUrl {
            asset = AVURLAsset.init(url: url as URL)
            self.createImageFramesforCrop(strUrl: url)
            setVideoDuration(url)
        }
    }
    
    //MARK: Video Play Action
    func addVideoPlayer(videoUrl: URL, to view: UIView) {
        self.avplayer = AVPlayer(url: videoUrl)
        playerController.player = self.avplayer
        self.addChild(playerController)
        view.addSubview(playerController.view)
        playerController.view.frame = view.bounds
        playerController.showsPlaybackControls = true
        self.avplayer.play()
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

extension CreateVideoViewController {
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
        let time: CMTime = CMTimeMakeWithSeconds(Float64(self.videoPlaybackPosition), preferredTimescale: self.avplayer.currentTime().timescale)
        self.avplayer.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        
        if(pos == CGFloat(videoTotalSeconds)) {
            self.avplayer.pause()
        }
    }
}

extension CreateVideoViewController {
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
            let videoModel = VideoModel()
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
                numberOfCroppedVideos += 1
                outputURL = outputURL.appendingPathComponent("\(numberOfCroppedVideos).mp4")
                videoModel.oroginalPath = outputURL
                croppedVideos.append(videoModel)
                                
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
                        
                        self.collectionView.reloadData()
                        let numberOfItems = self.collectionView.numberOfItems(inSection: 0)
                        let cellsHeight = (numberOfItems * 120 )
                        let spacingHeight = ((numberOfItems - 1) * 10)
                        self.croppedCollectionViewHeightConstrain.constant = CGFloat(cellsHeight + spacingHeight)
                    }
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

extension CreateVideoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        return outputURLs.count
        return croppedVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CroppedVideoCollectionViewCell",
            for: indexPath) as? CroppedVideoCollectionViewCell
            else { return UICollectionViewCell() }
        
        if let editedPath = croppedVideos[indexPath.row].editedPath {
            
            cell.videoUrl = editedPath
        } else {
            cell.videoUrl = croppedVideos[indexPath.row].oroginalPath
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: CGFloat(width), height: CGFloat(100))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        let vc = CroppedVideoToolsViewController(nibName: "CroppedVideoToolsViewController", bundle: nil)
        vc.index = indexPath.row
        vc.videoModel = croppedVideos[indexPath.row]
        vc.delegate = self
        
        self.present(vc, animated: true, completion: nil)
        
    }
}

extension CreateVideoViewController: CroppedVideoDelegate{
    func croppedVideoMerged() {
        collectionView.reloadData()
    }
    
}
