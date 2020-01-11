//
//  AudioRecorder.swift
//  ViedoMaker
//
//  Created by Mohammed Khaled on 1/11/20.
//  Copyright © 2020 Ibtikar. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol AudioRecorderDelegate: class {
    func audioRecordingFinished(_ url: URL)
}

open class AudioRecorderView: UIView {
    
    @IBOutlet private weak  var recordButton: UIButton!
    @IBOutlet private weak  var playButton: UIButton!
    @IBOutlet private weak  var mergeButton: UIButton!
    @IBOutlet private weak  var recordingTimeLabel: UILabel!
    
    var audioPlayer : AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    var recordingSession: AVAudioSession!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    
    weak var delegate: AudioRecorderDelegate?
    
    func setupView() {
        check_record_permission()
    }
    
    @objc func updateAudioMeter(timer: Timer)
    {
        if audioRecorder.isRecording
        {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recordingTimeLabel.text = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    func check_record_permission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            self.setupAudioRecording()
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.setupAudioRecording()
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getFileUrl() -> URL {
        let filename = "myRecording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    func setupAudioRecording() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 1
        self.recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try self.recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            try self.recordingSession.setActive(true)
            self.recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.recordButton.addGestureRecognizer(longPressGestureRecognizer)
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    // Gesture Recognizer for the Record Button, so as long as it is pressed, record!
    @objc func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer){
        if longPressGestureRecognizer.state == .ended {
            print("long press ended")
            let recordImage = UIImage(named: "ic-record")
            recordButton.setImage(recordImage, for: .normal)
            self.finishRecording(success: true)
        }
        if longPressGestureRecognizer.state == .began {
            let recordingTapImage = UIImage(named: "ic-record")
            recordButton.setImage(recordingTapImage, for: .normal)
            self.startRecording()
            
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("myRecording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
//        recordingSession = AVAudioSession.sharedInstance()
        do {
            try self.recordingSession.setActive(false)
        } catch {
            
        }
//        audioRecorder.stop()
//        audioRecorder = nil
//
//        if success {
//            recordButton.setTitle("Tap to Re-record", for: .normal)
//        } else {
//            recordButton.setTitle("Tap to Record", for: .normal)
//        }
    }
}

//player
extension AudioRecorderView {
    func preparePlay() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: getFileUrl())
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func playRecording(_ sender: Any) {
        if(isPlaying) {
            audioPlayer.stop()
            recordButton.isEnabled = true
//            playButton.setTitle("Play", for: .normal)
            let playImage = UIImage(named: "ic-play")
            playButton.setImage(playImage, for: .normal)
            isPlaying = false
        } else {
            if FileManager.default.fileExists(atPath: getFileUrl().path) {
                recordButton.isEnabled = false
//                playButton.setTitle("pause", for: .normal)
                let playImage = UIImage(named: "ic-pause")
                playButton.setImage(playImage, for: .normal)
                preparePlay()
                audioPlayer.play()
                isPlaying = true
            } else {
                print("Audio file is missing.")
            }
        }
    }
}

extension AudioRecorderView: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        setPlayerOff()
    }
    
    private func setPlayerOff() {
        audioPlayer.stop()
        isPlaying = false
        let playImage = UIImage(named: "ic-play")
        playButton.setImage(playImage, for: .normal)
        recordButton.isEnabled = true
    }
}

extension AudioRecorderView: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        } else {
            finishRecording(success: true)
        }
        delegate?.audioRecordingFinished(getFileUrl())
    }
}


