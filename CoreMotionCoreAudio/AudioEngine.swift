
import AudioKit
import CoreAudio

let DADefaultKickName = "kick-dry"
let DADefaultSnareName = "snare-brute"
let DADefaultHatName = "hihat-plain"
let DADefaultNote = 60
let DAPreparationDelay = 0.1
let DASoundLength = 0.7

protocol AudioModelDelegate {
	func startedRecording()
	func stoppedRecording()
}

public class AudioEngine: NSObject, AVAudioRecorderDelegate {
	
	let kick: AKSampler
	let hat: AKSampler
	let snare: AKSampler
	let reverb: AKReverb
	
	var isRecording = false
	var recordingAllowed = false
	var recordNotEmpty = false
	
	var currentURL = NSURL()
	
	var recorderDelegate: AudioModelDelegate?
	
	let recordingSession = AVAudioSession.sharedInstance()
	var audioRecorder: AVAudioRecorder?
	var audioPlayer: AVAudioPlayer?
	var note: Int = DADefaultNote
	
	override init() {
		
		kick = AKSampler()
		snare = AKSampler()
		hat = AKSampler()
		
		kick.loadWav(DADefaultKickName)
		snare.loadWav(DADefaultSnareName)
		hat.loadWav(DADefaultHatName)
		
		let mix = AKMixer(kick, snare, hat)
		reverb = AKReverb(mix)
		
		AudioKit.output = reverb
		AudioKit.start()
		
		reverb.loadFactoryPreset(.MediumRoom)
		
		super.init()
	}
	
	func record() {
		guard !isRecording && recordingAllowed
			else {
				return
		}
		recorderDelegate?.startedRecording()
		delay(DAPreparationDelay) {
			self.startRecording()
			delay(DASoundLength) {
				self.stopRecording()
				self.recorderDelegate?.stoppedRecording()
			}
		}
	}
	
	func prepareForRecording() {
		do {
			try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
			try recordingSession.setActive(true)
			recordingSession.requestRecordPermission() { allowed in
				self.recordingAllowed = allowed
			}
		} catch {
			fatalError("Cannot start recording session")
		}
	}
	
	func startRecording() {
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		guard let documentsDirectory = paths.first
			else {
				return
		}
		currentURL = NSURL(fileURLWithPath: documentsDirectory).URLByAppendingPathComponent("recording.m4a")
		
		let settings = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
			AVSampleRateKey: 12000.0,
			AVNumberOfChannelsKey: 1 as NSNumber,
			AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
		]
		
		do {
			audioRecorder = try AVAudioRecorder(URL: currentURL, settings: settings)
			audioRecorder?.delegate = self
			audioRecorder?.record()
			isRecording = true
		} catch {
		}
	}
	
	func stopRecording() {
		audioRecorder?.stop()
		audioRecorder = nil
		isRecording = false
	}
	
	public func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
		stopRecording()
	}

}

extension AudioEngine: SequencerAudioModel {
	func playKick(velocity: Int) {
		kick.playNote(note, velocity: velocity)
	}
	
	func playSnare(velocity: Int) {
		snare.playNote(note, velocity: velocity)
	}

	func playHat(velocity: Int) {
		hat.playNote(note, velocity: velocity)
	}
	
	func playRecord() {
		do {
			audioPlayer = try AVAudioPlayer(contentsOfURL: currentURL)
			audioPlayer?.volume = 0.5
			audioPlayer?.prepareToPlay ()
			audioPlayer?.play()
		} catch {
			
		}
	}
	
	func stopAllNotes() {
		kick.stopNote()
		snare.stopNote()
		hat.stopNote()
	}
}