//
//  Sequencer.swift
//  CoreMotionCoreAudio
//
//  Created by m.rakhmanov on 21.06.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import CoreMotion
import AudioKit

let DASequenceCount = 16

let DAStartingBPM = 80.0
let DAMaxAdditionalBPM = 60.0

let DABeatsPerUnit = 4
let DASecondsInMinute = 60.0

let DADefaultVelocity = 80
let DAMaxVelocity = 127
let DAMinVelocity = 60

protocol SequencerPatternDelegate {
	func randomizeEventDidOccur(kickSequence: BeatSequence, snareSequence: BeatSequence, hatSequence: BeatSequence)
	func newBeatDidPlayAtPosition(position: Int)
	func tempoDidChange(tempo: Double)
}

protocol SequencerAudioModel {
	func playKick(velocity: Int)
	func playSnare(velocity: Int)
	func playHat(velocity: Int)
	func playRecord()
	func stopAllNotes()
}

public class Sequencer {
	
	let sequenceCount = DASequenceCount
	let sequenceTransformer = SequenceTransformer()
	
	var patternDelegate: SequencerPatternDelegate?
	var audioEngine: SequencerAudioModel?
	
	var kickSequence: BeatSequence
	var snareSequence: BeatSequence
	var hatSequence: BeatSequence
	
	var counter: Int
	var currentBPM: Double
	var stopped = false
	
	init() {
		self.kickSequence = Array(count: sequenceCount, repeatedValue: false)
		self.snareSequence = Array(count: sequenceCount, repeatedValue: false)
		self.hatSequence = Array(count: sequenceCount, repeatedValue: false)
		self.counter = 0
		self.currentBPM = DASecondsInMinute
	}
	
	public func setBpmForMotion(motion: CMDeviceMotion) {
		let length = fabs(motion.gravity.y)
		currentBPM = DAStartingBPM + length * DAMaxAdditionalBPM
	}
	
	public func randomize() {
		kickSequence = sequenceTransformer.transformSequence(kickSequence)
		snareSequence = sequenceTransformer.transformSequence(snareSequence)
		hatSequence = sequenceTransformer.transformSequence(hatSequence)
		
		sequenceTransformer.recalculateChangePosition(sequenceCount)
		patternDelegate?.randomizeEventDidOccur(kickSequence, snareSequence: snareSequence, hatSequence: hatSequence)
	}
	
	public func stop() {
		audioEngine?.stopAllNotes()
		stopped = true
	}
	
	public func start() {
		stopped = false
	}
	
	public func playBeat() {
		
		repeatingDelay({ [weak self] in
			
			guard let sself = self else { return 0 }
			
			let newTempo = DASecondsInMinute / (sself.currentBPM * DABeatsPerUnit)
			return newTempo
			
			}, closure: { [weak self] in
				
				guard let sself = self else { return }
				sself.patternDelegate?.tempoDidChange(sself.currentBPM)
				sself.patternDelegate?.newBeatDidPlayAtPosition(sself.counter)
				sself.play()
		})
	}
	
	private func play() {
		guard !stopped else { return }
		
		let accentedBeat = (counter - 1) % 4 == 0
		let kickSnareVelocity = accentedBeat ? DAMaxVelocity : randomInt(DAMinVelocity ..< DAMaxVelocity)
		
		let hatVelocity = DADefaultVelocity
		
		if kickSequence[counter] {
			audioEngine?.playKick(kickSnareVelocity)
		}
		if snareSequence[counter] {
			audioEngine?.playSnare(kickSnareVelocity)
		}
		if hatSequence[counter] {
			audioEngine?.playHat(hatVelocity)
		}

		counter = (counter == sequenceCount - 1) ? 0 : counter + 1
	}

}