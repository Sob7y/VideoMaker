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
import MediaPlayer

class CroppedVideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var view: UIView!

//    weak var delegate: UpdateVideoUrlDelegate?

    var asset: AVAsset!
    var avplayer = AVPlayer()
    var playerController = AVPlayerViewController()

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
        
        // Initialization code
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
        view.backgroundColor = .darkGray
    }
}
