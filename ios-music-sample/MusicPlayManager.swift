//
//  MusicPlayManager.swift
//  ios-music-sample
//
//  Created by owen on 2019/12/11.
//  Copyright © 2019 nekowen. All rights reserved.
//

import SwiftUI
import AVFoundation

class MusicPlayManager: ObservableObject {
    enum PlayStatus {
        case prepared
        case stopped
        case playing
        case paused
    }
    
    struct EQParameter {
        let type: AVAudioUnitEQFilterType
        let bandWidth: Float?
        let frequency: Float
        let gain: Float
    }
    
    @Published var playStatus: PlayStatus = .stopped
    
    //  10-Bands Parametric EQ
    private var eqParameters: [EQParameter] = [
        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 32.0, gain: 3.0),
        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 64.0, gain: 3.0),
        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 128.0, gain: 3.0),
        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 256.0, gain: 2.0),
        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 500.0, gain: 0.0),
        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 1000.0, gain: -6.0),
        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 2000.0, gain: -6.0),
        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 4000.0, gain: -6.0),
        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 8000.0, gain: -6.0),
        EQParameter(type: .parametric, bandWidth: 1.0, frequency: 16000.0, gain: -6.0)
    ]
    
    private lazy var playerNode = AVAudioPlayerNode()
    private lazy var engine = AVAudioEngine()
    private var eqNode: AVAudioUnitEQ
    
    private var routeChangeNotificationObserver: NSObjectProtocol?
    
    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
                
        self.eqNode = AVAudioUnitEQ(numberOfBands: self.eqParameters.count)
        self.eqNode.bands.enumerated().forEach { index, param in
            param.filterType = self.eqParameters[index].type
            param.bypass = false
            if let bandWidth = self.eqParameters[index].bandWidth {
                param.bandwidth = bandWidth
            }
            param.frequency = self.eqParameters[index].frequency
            param.gain = self.eqParameters[index].gain
        }
        
        self.engine.attach(self.playerNode)
        self.engine.attach(self.eqNode)
        
        self.registerRouteChangeObserver()
    }
    
    deinit {
        self.removeRouteChangeObserver()
    }
    
    private func registerRouteChangeObserver() {
        self.routeChangeNotificationObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification, object: nil, queue: nil) { [weak self] notification in
            guard let userInfo = notification.userInfo,
                let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
            }
            
            DispatchQueue.main.async {
                switch reason {
                case .newDeviceAvailable:
                    try? self?.play()
                case .oldDeviceUnavailable:
                    self?.pause()
                default: break
                }
            }
        }
    }
    
    private func removeRouteChangeObserver() {
        if let routeChangeNotificationObserver = self.routeChangeNotificationObserver {
            NotificationCenter.default.removeObserver(routeChangeNotificationObserver)
        }
    }
    
    func prepare(_ item: MusicItem) throws {
        guard let path = item.assetURL else {
            return
        }
        let audioFile = try AVAudioFile(forReading: path)
        
        self.engine.connect(self.playerNode, to: self.eqNode, format: audioFile.processingFormat)
        self.engine.connect(self.eqNode, to: self.engine.mainMixerNode, format: audioFile.processingFormat)
        try self.engine.start()
        self.playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        self.playStatus = .prepared
    }
    
    func play() throws {
        guard self.engine.isRunning else {
            return
        }
        try AVAudioSession.sharedInstance().setActive(true, options: [])
        self.playerNode.play()
        self.playStatus = .playing
    }
    
    func stop() {
        self.playerNode.stop()
        self.engine.stop()
        self.playStatus = .stopped
    }
    
    func pause() {
        self.playerNode.pause()
        self.engine.pause()
        self.playStatus = .paused
    }
}
