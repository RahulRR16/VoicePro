//
//  ViewController.swift
//  VoiceGo
//
//  Created by Rahul on 15/10/24.
//

import UIKit
import AVFoundation

class HomeVC: BaseViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var circleViewThree: UIView!
    @IBOutlet weak var circleViewTwo: UIView!
    @IBOutlet weak var circleViewOne: UIView!
    @IBOutlet weak var recordImg: UIImageView!
    @IBOutlet weak var recordStopBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var magicVoiceBtn: UIButton!
    
    var timer: Timer?
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var audioPlayerNode: AVAudioPlayerNode!
    var recordedAudioURL: URL!
    var isRecording: Bool = false
    var isPlaying = false
    var isPaused = false
    var elapsedTime: Double = 0.0
    var totalDuration: TimeInterval = 0.0
    var selectedEffect: String = "None"
    
    // Core Data context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        setupAudioSession()
    }
    
    func setupUi() {
        playPauseBtn.isHidden = true
        circleViewThree.layer.masksToBounds = true
        circleViewThree.layer.cornerRadius = circleViewThree.frame.height / 2
        circleViewTwo.layer.masksToBounds = true
        circleViewTwo.layer.cornerRadius = circleViewTwo.frame.height / 2
        circleViewOne.layer.masksToBounds = true
        circleViewOne.layer.cornerRadius = circleViewOne.frame.height / 2
        
        recordStopBtn.layer.cornerRadius = 18
        recordStopBtn.setTitleColor(.white, for: .normal)
        playPauseBtn.tintColor = .white
        playPauseBtn.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            session.requestRecordPermission { granted in
                if granted {
                    print("Permission granted")
                } else {
                    print("Permission denied")
                }
            }
        } catch {
            print("Failed to set up audio session")
        }
    }
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        if isPlaying {
            pauseAudio()
        } else {
            if isPaused {
                resumeAudio()
            } else {
                playOriginalAudio()
            }
        }
    }
    
    @IBAction func actionForMagicVoice(_ sender: Any) {
        let alert = UIAlertController(title: "Select Audio Effect", message: nil, preferredStyle: .actionSheet)
        
        let effects = ["None", "Chipmunk", "Echo", "Reverb", "DarthVader"]
        for effect in effects {
            alert.addAction(UIAlertAction(title: effect, style: .default, handler: { _ in
                self.selectedEffect = effect
                self.magicVoiceBtn.setTitle(effect, for: .normal)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // Add Save button functionality
    @IBAction func saveAudio(_ sender: UIButton) {
        guard let recordedAudioURL = recordedAudioURL else {
            print("No recorded audio to save.")
            return
        }
        
        // Generate a unique file name (you can change this to something meaningful)
        let fileName = "Audio_\(Date().timeIntervalSince1970).m4a"
        
        // Save audio metadata to Core Data
        let newAudioFile = AudioFile(context: context)
        newAudioFile.fileName = fileName
        newAudioFile.fileURL = recordedAudioURL.absoluteString
        print("check--\(recordedAudioURL.absoluteString)")
        do {
            try context.save()
            showSaveSuccessPopup()
        } catch {
            print("Failed to save audio file: \(error)")
        }
    }
    
    @IBAction func viewSavedFiles(_ sender: UIButton) {
        let savedAudioListVC = self.storyboard?.instantiateViewController(withIdentifier: "AudioFileListVC") as! AudioFileListVC
        self.navigationController?.pushViewController(savedAudioListVC, animated: true)
    }
    
    @IBAction func actionForRecordStop(_ sender: Any) {
        if !isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    // Show popup for saved success
    func showSaveSuccessPopup() {
        let alert = UIAlertController(title: "Saved", message: "Audio saved successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func startRecording() {
        isRecording = true
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recordedVoice.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()
            recordedAudioURL = audioFilename
            playPauseBtn.isHidden = true
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        isRecording = false
        // Adding a delay to ensure all audio data is written to the file
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.audioRecorder.stop()
            self.playPauseBtn.isHidden = false
            print("Recording stopped")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func playOriginalAudio() {
        
        guard let recordedAudioURL = recordedAudioURL else {
            print("No audio file found.")
            return
        }
        
        if audioEngine == nil {
            audioEngine = AVAudioEngine()
        }
        
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.reset()
        }
        
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL)
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
            return
        }
        
        
        totalDuration = Double(audioFile.length) / audioFile.processingFormat.sampleRate
        applySelectedEffect()
        //  audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, at: nil) { [weak self] in
            DispatchQueue.main.async {
                self?.resetUIAfterPlayback()
            }
        }
        
        do {
            try audioEngine.start()
            audioPlayerNode.play()
            startProgressTracking(playerNode: audioPlayerNode, duration: totalDuration)
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
        
        isPlaying = true
        isPaused = false
        playPauseBtn.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    
    // Apply the effect based on user's selection
    func applySelectedEffect() {
        switch selectedEffect {
            
        case "Chipmunk":
            let chipmunkNode = AVAudioUnitTimePitch()
            chipmunkNode.pitch = 1000
            audioEngine.attach(chipmunkNode)
            audioEngine.connect(audioPlayerNode, to: chipmunkNode, format: nil)
            audioEngine.connect(chipmunkNode, to: audioEngine.mainMixerNode, format: nil)
            
        case "Echo":
            let delayEffect = AVAudioUnitDelay()
            delayEffect.delayTime = 0.5
            audioEngine.attach(delayEffect)
            audioEngine.connect(audioPlayerNode, to: delayEffect, format: nil)
            audioEngine.connect(delayEffect, to: audioEngine.mainMixerNode, format: nil)
            
        case "Reverb":
            let reverbNode = AVAudioUnitReverb()
            reverbNode.loadFactoryPreset(.cathedral)
            reverbNode.wetDryMix = 50
            audioEngine.attach(reverbNode)
            audioEngine.connect(audioPlayerNode, to: reverbNode, format: nil)
            audioEngine.connect(reverbNode, to: audioEngine.mainMixerNode, format: nil)
            
        case "DarthVader":
            let pitchNode = AVAudioUnitTimePitch()
            pitchNode.pitch = -1000  // 1200 cents = 1 octave
            audioEngine.attach(pitchNode)
            audioEngine.connect(audioPlayerNode, to: pitchNode, format: nil)
            audioEngine.connect(pitchNode, to: audioEngine.mainMixerNode, format: nil)
            
        default:
            audioEngine.connect(audioPlayerNode, to: audioEngine.mainMixerNode, format: nil)
        }
    }
    
    func pauseAudio() {
        if isPlaying {
            audioPlayerNode.pause()
            timer?.invalidate()  // Stop the timer while paused
            playPauseBtn.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
            isPlaying = false
            isPaused = true
        }
    }
    
    func resumeAudio() {
        if !isPlaying && isPaused {
            do {
                try audioEngine.start()
                audioPlayerNode.play()
                startProgressTracking(playerNode: audioPlayerNode, duration: totalDuration - elapsedTime)
                playPauseBtn.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
                isPlaying = true
                isPaused = false
            } catch {
                print("Error resuming audio engine: \(error.localizedDescription)")
            }
        }
    }
    
    func resetUIAfterPlayback() {
        audioEngine.stop()
        audioEngine.reset()
        playPauseBtn.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        progressBar.setProgress(0, animated: false)
        timerLabel.text = "00:00"
        isPlaying = false
        isPaused = false
    }
    
    func startProgressTracking(playerNode: AVAudioPlayerNode, duration: TimeInterval) {
        timer?.invalidate()
        totalDuration = duration
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let nodeTime = playerNode.lastRenderTime, let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {
                self.elapsedTime = Double(playerTime.sampleTime) / playerTime.sampleRate
                
                let progress = Float(self.elapsedTime / self.totalDuration)
                self.progressBar.setProgress(progress, animated: true)
                
                self.timerLabel.text = self.formatTime(self.elapsedTime)
            }
            
            if self.elapsedTime >= self.totalDuration {
                self.timer?.invalidate()
                self.resetUIAfterPlayback()
            }
        }
    }
    
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}
