//
//  AudioControllerDelegate.swift
//  iChat
//
//  Created by David Kababyan on 14/08/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import Foundation

class AudioContollerDelegate: NSObject, SINAudioControllerDelegate {
    
    var muted: Bool!
    var speaker: Bool!//not needed
    
    func audioControllerMuted(_ audioController: SINAudioController!) {
        self.muted = true
    }
    
    func audioControllerUnmuted(_ audioController: SINAudioController) {
        self.muted = false
    }
    
    //not needed
    func audioControllerSpeakerEnabled(_ audioController: SINAudioController!) {
        self.speaker = true
    }
    
    func audioControllerSpeakerDisabled(_ audioController: SINAudioController!) {
        self.speaker = false
    }
    
}
