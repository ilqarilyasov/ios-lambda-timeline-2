//
//  AddCommentViewController.swift
//  LambdaTimeline
//
//  Created by Ilgar Ilyasov on 11/7/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class AddCommentViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        recordButton.isEnabled = false
        playButton.isEnabled = false
    }

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectCommentType(_ sender: Any) {
        if commentTypeSegmentedControl.selectedSegmentIndex == 0 {
            commentTextField.isEnabled = true
            recordButton.isEnabled = false
            playButton.isEnabled = false
        } else {
            commentTextField.isEnabled = false
            recordButton.isEnabled = true
            playButton.isEnabled = true
            commentTextField.text = ""
        }
    }
    
    
    @IBAction func record(_ sender: Any) {
        defer { updateButton() }
        
        guard !isRecording else {
            recorder?.stop()
            return
        }
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
            recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            NSLog("Unable to start recording: \(error.localizedDescription)")
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingURL = recorder.url
        self.recorder = nil
        updateButton()
    }
    
    @IBAction func play(_ sender: Any) {
        defer { updateButton() }
        guard let audioURL = recordingURL else { return }
        
        guard !isPlaying else {
            player?.pause()
            return
        }
        
        if player != nil && !isPlaying {
            player?.play()
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.delegate = self
            player?.play()
        } catch {
            NSLog("Unable to play audio: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        updateButton()
    }
    
    @IBAction func send(_ sender: Any) {
        if let text = commentTextField.text, text != "" {
            self.postController?.addComment(with: text, to: &self.post!)
        } else if let audioURL = recordingURL {
            
            let data = try! Data(contentsOf: audioURL)
            self.postController?.storeAudio(audioData: data, completion: { (url) in
                guard let url2 = url else {
                    NSLog("Audio url not returned")
                    return
                }
                
                self.postController?.addComment2(with: url2, to: &self.post!)
            })
        }
    }
    
    class func requestRecordPermission() {
        let session = AVAudioSession.sharedInstance()
        
        session.requestRecordPermission { (granted) in
            guard granted else {
                NSLog("Please give the application permission to record in Settings")
                return
            }
            
            do {
                try session.setCategory(.playAndRecord, mode: .default, options: [])
                try session.setActive(true, options: [])
            } catch {
                NSLog("Error setting AVAudioSession: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateButton() {
        let recording = isRecording ? "Stop" : "Record"
        recordButton.setTitle(recording, for: .normal)
        
        let playing = isPlaying ? "Stop" : "Play"
        playButton.setTitle(playing, for: .normal)
    }
    
    private func newRecordingURL() -> URL {
        let dir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return dir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }
    
    var post: Post?
    var postController: PostController?
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var recordingURL: URL?
    
    private var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    private var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    @IBOutlet weak var commentTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
}
