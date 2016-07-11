//
//  BeatGenerator.swift
//  CoreMotionCoreAudio
//
//  Created by m.rakhmanov on 10.07.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import AudioKit

let DAPositionInterval = 4

class SequenceTransformer {
	
	var changePosition = DAPositionInterval
	
	func recalculateChangePosition(size: Int) {
		changePosition = randomInt(DAPositionInterval ... size)
	}

	func transformSequence(sequence: BeatSequence) -> BeatSequence {
		let	transformPattern = generateEveryNthBeatTransformPattern(sequence.count, number: changePosition)
		return transformSequence(sequence, withPattern: transformPattern)
	}
	
	private func generateEveryNthBeatTransformPattern(size: Int, number: Int) -> BeatSequence {
		var transformPattern = Array(count: size, repeatedValue: false)
		
		for index in 0 ..< transformPattern.count {
			if index % number == 0 {
				transformPattern[index] = true
			}
		}
		
		return transformPattern
	}
	
	private func generateHalfBeatTransformPattern(size: Int) -> BeatSequence {
		var transformPattern = Array(count: size, repeatedValue: false)
		let halfCount = size / 2
		var startIndex = 0
		var endIndex = halfCount
		
		if randomBool() {
			startIndex = halfCount
			endIndex = transformPattern.count
		}
		
		for index in startIndex ..< endIndex {
			transformPattern[index] = true
		}
		
		return transformPattern
	}

	
	private func transformSequence(sequence: BeatSequence, withPattern transformPattern: BeatSequence) -> BeatSequence {
		var newSequence: BeatSequence = sequence
		
		for index in 0 ..< newSequence.count {
			if transformPattern[index] {
				newSequence[index] = randomBool()
			}
		}
		
		return newSequence
	}
	
	private func randomBool() -> Bool {
		let randomRange = 0...10
		let minRandomValue = 5
		
		return randomInt(randomRange) > minRandomValue
	}
	
}