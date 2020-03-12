//
//  SINCallKitProvider.swift
//  WChat
//
//  Created by David Kababyan on 01/05/2018.
//  Copyright © 2018 David Kababyan. All rights reserved.
//

import Foundation
import CallKit

class SINCallKitProvider: NSObject, CXProviderDelegate {
    
    var _client: SINClient!
    var _provider: CXProvider!
    var _acDelegate: AudioContollerDelegate!
    var _calls: [UUID : SINCall]
    var _muted: Bool


    
    init(withClient: SINClient) {
        
        _client = withClient
        _muted = false
        _acDelegate = AudioContollerDelegate()
        _client.audioController().delegate = _acDelegate
        _calls = [:]
        
        let config = CXProviderConfiguration(localizedName: "Wchat")
        config.maximumCallGroups = 1
        config.maximumCallsPerCallGroup = 1
        
        _provider = CXProvider(configuration: config)
        
        super.init()
        
        _provider.setDelegate(self, queue: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(callDidEnd), name: NSNotification.Name(rawValue: "SINCallDidEndNotification"), object: nil)
        
    }
    
    func reportNewIncomingCall (call: SINCall) {
        var caller = "WChat Call"
        if let call = call.headers[kFULLNAME] {
            caller = call as! String
        }
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: caller)

        _provider.reportNewIncomingCall(with: UUID(uuidString: call.callId)!, update: update) { (error) in
            if error != nil {
                print("error call \(error!.localizedDescription)")
                return
            }
            
            self.addNewCall(call: call)
        }
        
    }
    
    func addNewCall(call: SINCall) {
        print("Added call \(call.callId)")
        _calls[UUID(uuidString: call.callId)!] = call
    }
    
    // Handle cancel/bye event initiated by either caller or callee
    @objc func callDidEnd(notification: Notification) {
        
        if let call: SINCall = notification.userInfo![SINCallKey] as? SINCall {
            
            let cause = SINGetCallEndedReason(cause: call.details.endCause)
            
            _provider.reportCall(with: UUID(uuidString: call.callId)!, endedAt: call.details.endedTime, reason: cause)
            
            
            if self.callExist(callId: call.callId) {
                print("CallDidEnd, removing \(call.callId)")
                _calls.removeValue(forKey: UUID(uuidString: call.callId)!)
            }

        } else {
            print("warning no call was reported")
        }
        
        
    }
    
    
    func callExist (callId: String) -> Bool {
        
        if _calls.count == 0 {
            return false
        }

        for callKitCall in _calls.values {
            if callKitCall.callId == callId {
                return true
            }
        }
        return false
    }
    
    func activeCalls() -> [SINCall] {
        return Array(_calls.values)
    }
    
    func currentEstablishedCall () -> SINCall? {
        let calls = activeCalls()
        
        if calls.count == 1 && calls[0].state == SINCallState.established {
            return calls[0]
        } else {
            return nil
        }
    }


    
    
    
    //MARK: CXProvider delegate
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Did activate")
        _client.call()?.provider(provider, didActivate: audioSession)
    }
    
    func callForAction(action: CXCallAction) -> SINCall? {
        
        let call = _calls[action.callUUID]
        if call == nil {
            print("Warning no call found for action \(action.callUUID)")
            return nil
        }
        return call
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("Answer call action")

        callForAction(action: action)?.answer()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("end call action")
        callForAction(action: action)?.hangup()
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        print("mute call action")

        if _acDelegate.muted {
            _client.audioController().unmute()
        } else {
            _client.audioController().mute()
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        
        print("did diactivate audio session")
    }
    
    
    func providerDidReset(_ provider: CXProvider) {
        print("did reset")

    }

    
    //MARK: Helpers
    func SINGetCallEndedReason(cause: SINCallEndCause) -> CXCallEndedReason {
        switch cause {
        case .error:
            return CXCallEndedReason.failed
        case.denied:
            return CXCallEndedReason.remoteEnded
        case .hungUp:
            return CXCallEndedReason.remoteEnded
        case .timeout:
            return CXCallEndedReason.unanswered
        case .canceled:
            return CXCallEndedReason.unanswered
        case .noAnswer:
            return CXCallEndedReason.unanswered
        case .otherDeviceAnswered:
            return CXCallEndedReason.unanswered
        default:
            break
        }
        
        return CXCallEndedReason.failed
    }

    
}


