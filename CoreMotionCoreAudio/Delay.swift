//
//  Delay.swift
//  CoreMotionCoreAudio
//
//  Created by m.rakhmanov on 22.06.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation

let delayQueue: dispatch_queue_t = dispatch_get_main_queue()

func delay(delay: Double, closure: () -> ()) {
	dispatch_after (
		dispatch_time (
			DISPATCH_TIME_NOW,
			Int64 (delay * Double(NSEC_PER_SEC))
		),
		delayQueue, closure)
}

func repeatingDelay(closureDelay: () -> Double, closure: () -> ()) {
	delay(closureDelay()) {
		closure()
		repeatingDelay(closureDelay, closure: closure)
	}
}