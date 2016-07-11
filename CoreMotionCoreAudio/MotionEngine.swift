//
//  motionEngine.swift
//  CoreMotionCoreAudio
//
//  Created by m.rakhmanov on 19.06.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import CoreMotion

class MotionEngine {
	
	let motionQueue = NSOperationQueue.mainQueue()
	let motionManager = CMMotionManager()

	func startMotionUpdates(motionClosure: (CMDeviceMotion) -> ()) {
		motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
		if motionManager.deviceMotionAvailable {
			motionManager.startDeviceMotionUpdatesToQueue(motionQueue) { data, error in
				guard let data = data else { return }
				motionClosure(data)
			}
		}
	}
}