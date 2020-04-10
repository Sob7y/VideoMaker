//
//  VideoModel.swift
//  ViedoMaker
//
//  Created by Mahmoud Nasser on 4/10/20.
//  Copyright © 2020 Ibtikar. All rights reserved.
//

import Foundation
import AVKit

class VideoModel: NSObject {
    
    var name: String?
    var oroginalPath: URL?
    var editedPath: URL?
    var startTime: Float?
    var endTime: Float?
    var audioPath: URL?
    
    var startCMTime: CMTime? {
        return CMTime(seconds: Double(startTime ?? 0.0), preferredTimescale: 1000)
    }
    var endCMTime: CMTime? {
        return CMTime(seconds: Double(endTime ?? 0.0), preferredTimescale: 1000)
    }
    
}
