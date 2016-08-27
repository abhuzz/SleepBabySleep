//
//  Timer.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 27/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

protocol TimerExpiredDelegate {
    func timerExpired()
}

protocol Timer {
    func start(durationInSeconds: Double, callDelegateWhenExpired: TimerExpiredDelegate)
}

class SystemTimer: Timer {
    
    private var timer = NSTimer()
    private var expiredDelegate: TimerExpiredDelegate?
    
    func start(durationInSeconds: Double, callDelegateWhenExpired: TimerExpiredDelegate) {
        
        expiredDelegate = callDelegateWhenExpired
        
        timer =
            NSTimer.scheduledTimerWithTimeInterval(durationInSeconds, target: self, selector: #selector(SystemTimer.timerExpired), userInfo: nil, repeats: false)
    }
    
    @objc func timerExpired() {
        
        guard let delegate = expiredDelegate else { return }
        
        delegate.timerExpired()
    }
}