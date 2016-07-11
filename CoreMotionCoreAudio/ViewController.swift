//
//  ViewController.swift
//  CoreMotionCoreAudio
//
//  Created by m.rakhmanov on 19.06.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

let DAArrowDownCellIdentifier = "ArrowDownCell"
let DADrumCellIdentifier = "DrumCell"
let DAReferenceAcceleration = 2.5

class ViewController: UIViewController {
	
	let cellsPerScreen = DASequenceCount
	
	let motionEngine = MotionEngine()
	let audioEngine = AudioEngine()
	let sequencer = Sequencer()
	
	private var recordingAllowed = false
	
	@IBOutlet weak var tempoLabel: UILabel!
	@IBOutlet weak var arrowDownCollectionView: UICollectionView!
	@IBOutlet weak var kickCollectionView: UICollectionView!
	@IBOutlet weak var hatCollectionView: UICollectionView!
	@IBOutlet weak var snareCollectionView: UICollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureCollectionViews()
		sequencer.patternDelegate = self
		sequencer.audioEngine = audioEngine
		audioEngine.recorderDelegate = self
		
		motionEngine.startMotionUpdates { data in
			if data.userAcceleration > DAReferenceAcceleration {
				self.sequencer.randomize()
			}
			self.sequencer.setBpmForMotion(data)
		}
		sequencer.playBeat()
		audioEngine.prepareForRecording()
	}
	
	// MARK: Методы создания collection view
	
	func configureCollectionViews() {
		configureKickCollectionView()
		configureSnareCollectionView()
		configureArrowDownCollectionView()
		configureHatCollectionView()
	}
	
	func configureArrowDownCollectionView() {
		let layout = layoutForCollectionView()
		arrowDownCollectionView.collectionViewLayout = layout
		arrowDownCollectionView.dataSource = self
		arrowDownCollectionView.delegate = self
	}
	
	func configureKickCollectionView() {
		let layout = layoutForCollectionView()
		kickCollectionView.collectionViewLayout = layout
		kickCollectionView.dataSource = self
		kickCollectionView.delegate = self
	}
	
	func configureSnareCollectionView() {
		let layout = layoutForCollectionView()
		snareCollectionView.collectionViewLayout = layout
		snareCollectionView.dataSource = self
		snareCollectionView.delegate = self
	}
	
	func configureHatCollectionView() {
		let layout = layoutForCollectionView()
		hatCollectionView.collectionViewLayout = layout
		hatCollectionView.dataSource = self
		hatCollectionView.delegate = self
	}
	
	// MARK: методы заполнения collection view
	
	func setDrumGrid(sequence: [Bool], forCollection collection: UICollectionView) {
		for indexPath in collection.indexPathsForVisibleItems() {
			changeCellActiveForDrumCollection(collection, atIndexPath: indexPath, active: sequence[indexPath.row])
		}
	}
	
	func setArrowGrid(counter: Int) {
		for indexPath in arrowDownCollectionView.indexPathsForVisibleItems() {
			if let cell = arrowDownCollectionView.cellForItemAtIndexPath(indexPath) as? ArrowDownCell {
				cell.setActive(indexPath.row == counter)
			}
		}
	}
	
	func changeCellActiveForDrumCollection(collection: UICollectionView,
	                                       atIndexPath indexPath: NSIndexPath,
	                                                   active: Bool) {
		if let cell = collection.cellForItemAtIndexPath(indexPath) as? DrumCell {
			cell.setActive(active)
		}
	}

	// MARK: методы подготовки collection view
	
	func layoutForCollectionView() -> UICollectionViewFlowLayout {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		layout.scrollDirection = .Horizontal
		layout.itemSize = CGSize(width: calculateItemWidth(cellsPerScreen),
		                         height: hatCollectionView.frame.height)
		
		return layout
	}
	
	func calculateItemWidth(amountOfCellsInRow: Int) -> CGFloat {
		return self.view.frame.width / CGFloat(amountOfCellsInRow)
	}
	
	@IBAction func recordSound(sender: AnyObject) {
		audioEngine.record()
	}
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return cellsPerScreen
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell: UICollectionViewCell!
		if collectionView == arrowDownCollectionView {
			cell = collectionView.dequeueReusableCellWithReuseIdentifier(DAArrowDownCellIdentifier, forIndexPath: indexPath)
		} else {
			cell = collectionView.dequeueReusableCellWithReuseIdentifier(DADrumCellIdentifier, forIndexPath: indexPath)
		}
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		guard collectionView != arrowDownCollectionView else { return }
		
		let index = indexPath.row
		var changedValue: Bool = false
		
		if collectionView == kickCollectionView {
			sequencer.kickSequence[index] = !sequencer.kickSequence[index]
			changedValue = sequencer.kickSequence[index]
		}
		if collectionView == snareCollectionView {
			sequencer.snareSequence[index] = !sequencer.snareSequence[index]
			changedValue = sequencer.snareSequence[index]
		}
		if collectionView == hatCollectionView {
			sequencer.hatSequence[index] = !sequencer.hatSequence[index]
			changedValue = sequencer.hatSequence[index]
		}
		changeCellActiveForDrumCollection(collectionView,
		                                  atIndexPath: indexPath,
		                                  active: changedValue)
	}
}

extension ViewController: SequencerPatternDelegate {
	func tempoDidChange(tempo: Double) {
		let tempoIntValue = Int(tempo)
		tempoLabel.text = String(tempoIntValue)
	}
	
	func newBeatDidPlayAtPosition(position: Int) {
		dispatch_async(dispatch_get_main_queue(), {
			self.setArrowGrid(position)
		})
	}
	
	func randomizeEventDidOccur(kickSequence: BeatSequence, snareSequence: BeatSequence, hatSequence: BeatSequence) {
		setDrumGrid(kickSequence, forCollection: kickCollectionView)
		setDrumGrid(snareSequence, forCollection: snareCollectionView)
		setDrumGrid(hatSequence, forCollection: hatCollectionView)
	}
}

extension ViewController: AudioModelDelegate {
	func stoppedRecording() {
		sequencer.start()
	}
	
	func startedRecording() {
		sequencer.stop()
	}
}
