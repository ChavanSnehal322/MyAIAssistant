//
//  ViewModel.swift
//  MyAIAssistant
//
//  Created by Snehal Chavan on 7/12/25.
//

import Foundation
import AVFoundation
import Observation
//import XCAOpenAIClient
import Speech

@Observable
class ViewModel: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    
    // let client = OpenAIClient(apiKey: "....")  // using API key
    
    // additional properties defination
    
    var audioPlayer : AVAudioPlayer!  // wrapping implicitly
    var audioRecorder: AVAudioRecorder!
    
    #if !os(macOS)
    var recordingSession = AVAudioSession.sharedInstance()
    #endif
    
    var animationTimer: Timer?  // optional
    
    var recordingTimer : Timer?         // recognize when user stops talking
    var audioPower = 0.0
    
    var prevAudioPower: Double?
    
    // optional
    var processingSpeechTask: Task<Void, Never>?
    
    var selectedVoice = VoiceType.alloy
    
    var captureURL: URL{
        // the file will be stored in cacheDirectory
        FileManager.default.urls( for: .cachesDirectory, in: .userDomainMask)
            .first!.appendingPathComponent("recording.m4a")
        
    }
    
    var state = VoiceChatState.idle{
        
        didSet { print(state) }
    }
    
    var isIdle: Bool{
        
        if case .idle = state {
            return true
        }
        
        return false
    }
    
    // var audioPower = 0.0
    var siriWaveFromOpacity: CGFloat{
        
        switch state{
            
        case .recordingSpeech, .answeringSpeech: return 1
            
        default : return 0
            
        }
    }
    
    override init(){
        
        super.init()
        
        #if !os(macOS)
        do{
            
            // errror handling
            
            // check if od is iOS
            #if os(iOS)
            
            // pass audio to speaker of mobile
            try recordingSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            
            #else
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            
            #endif
            // set session to active
            try recordingSession.setActive(true)
            
            AVAudioApplication.requestRecordPermission{
                // unowned as we have instance for whole viewModel
                [unowned self] allowed in
                
                if !allowed{
                    
                    self.state = .error(" Recording not permitted by the user " as! Error)
                }
            }
            
        }catch{
            state = .error(error)
        }
        #endif
    }
    
    
    func startCaptureAudio(){
        
        // reset the values initially
        resetValue()
        
        // set the state
        state = .recordingSpeech
        do{
            // initialize the audio recorder
            audioRecorder = try AVAudioRecorder( url: captureURL,
                                                 // passing dictonary
                                                 settings: [
                                                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                                            AVSampleRateKey: 12000,
                                                            AVNumberOfChannelsKey: 1,
                                                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue])
            
            // automatically compress the audio file
            // monitor the meter of average power of the recording
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            
            // start the recording
            audioRecorder.record()
            
            //
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [ unowned self]_ in
                // check if self audio recorder is not null
                guard self.audioRecorder != nil else {return}
                
                // get the new meter power of recording
                self.audioRecorder.updateMeters()
                
                // range is between -30 to +30 for humans
                
                // normalizing the power failure between 0 and 1 using the below formula
                let power = min(1, max(0, 1 - abs( Double(self.audioRecorder.averagePower(forChannel: 0)) / 50 )  ))
                
                // update the siri animation
                self.audioPower = power
                
            })
            
            // scheduling a timer that repeats for every 1.6 seconds
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true, block: { [unowned self]_ in
                
                guard self.audioRecorder != nil else {return}
                self.audioRecorder.updateMeters()
                
                // normalizing the power failure between 0 and 1 using the below formula
                let power = min(1, max(0, 1 - abs( Double(self.audioRecorder.averagePower(forChannel: 0)) / 50 )  ))
                
                if self.prevAudioPower == nil{
                    
                    self.prevAudioPower = power
                    return
                }
                
                // if the prevVideo power & prevAudioPower is < 0.25 & current power < 0.175
                if let prevAudioPower = self.prevAudioPower, prevAudioPower < 0.25 && power < 0.175{
                    
                    // invoke the finichCapture audio & start processing it
                    self.finishCaptureAudio()
                    return
                    
                }
                
                // reupdate the prevAudioPower
                self.prevAudioPower = power
                
            })
            
        }
        catch{
            resetValue()
            state = .error(error)
        }
        
        
    }
    
    func finishCaptureAudio()
    {
        resetValue()
        
        do{
            //  creating a data to check if data is pesent & capture the url
            let data = try Data( contentsOf: captureURL)
            
            // process the speech audio by passing audio data
            processingSpeechTask = processSpeechTask(audioData: data)
            
        }catch
        {
            state = .error(error)
            resetValue()
        }
        
    }
    
//    // accepts audio data & return Task for OpenAI api
//    func processSpeechTask( audioData : Data) -> Task<Void, Never>{
//        
//        Task {
//            // run the task as main actor
//            @MainActor [unowned self] in
//            
//            do {
//                
//                // set the state to process the speech
//                self.state = .processingSpeech
//                // store the prompt sent by the user as a audio transcript
//                let prompt = try await client.generateAudioTransciptions(audioData: audioData)
//                
//                // check if task is cancelled
//                try Task.checkCancellation()
//                // store the prompt response from chatgpt model
//                let responseText = try await client.promptChatGPT(prompt: prompt)
//                
//                // check if task is cancelled by user
//                try Task.checkCancellation()
//                
//                // generate the speech form of the response to be given to the user
//                // pass the text and vois type to be selected from the available list, alloy by default
//                let data = try await client.generateSpeechFrom(input: responseText, voice:
//                        .init(rawValue: selectedVoice.rawValue) ?? .alloy)
//                
//                // check if task is cancelled by user
//                try Task.checkCancellation()
//                
//                // play the response of the user query answer
//                try self.PlayAudio(data: data)
//            }
//            catch{
//                // cancelable task by user, so return
//                if Task.isCancelled { return }
//                // set state to error
//                state = .error(error)
//                resetValue()
//            }
//        }
//    }
    
    func transcribeAudio(url: URL) async throws -> String {
        
        // Create a speech recognizer for English (US). It's a object that will process the audio into text
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
        
        // Create a recognition request that points to the audio file on disk. It tells the recognizer to transcribe the audio at 'url'.
        let request = SFSpeechURLRecognitionRequest(url: url)

        // Wraping the completion-handler based API (recognitionTask) into Swift Concurrency withCheckedThrowingContinuation, so we can 'await' the result.
        return try await withCheckedThrowingContinuation {
            continuation in
            
            // Starts recognition. This runs asynchronously and calls back multiple times with partial and final results.
            recognizer.recognitionTask(with: request) {
                result, error in
                
                // If any error, resume the async call by throwing it.
                if let error = error {
                    continuation.resume(throwing: error)
                }
                // If we got a final complete result (not partial), return the transcribed text.
                else if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }
    
    let client = OllamaClient()
    
    func processSpeechTask( audioData : Data) -> Task<Void, Never>{
        
        Task {
            @MainActor [unowned self] in
                do {
                    self.state = .processingSpeech

                    // 1. Transcribe using Apple Speech
                    let prompt = try await transcribeAudio(url: captureURL)

                    // check if task is cancelled by user
                    try Task.checkCancellation()

                    // 2. Chat with Ollama model
                    let responseText = try await client.chat(
                        model: "llama2:latest",
                        messages: [["role": "user", "content": prompt]]
                    )

                    // check if task is cancelled by user
                    try Task.checkCancellation()

                    // 3. Text-to-Speech with AVFoundation
                    self.state = .answeringSpeech
                    let utterance = AVSpeechUtterance(string: responseText)
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)

                } catch {
                    
                    // check if task is cancelled by user, return the fuction call
                    if Task.isCancelled { return }
                    
                    // set state to error
                    state = .error(error)
                    resetValue()  // reset all the values for the app
                }
            }
        }
    
    func PlayAudio( data: Data) throws
    {
        // setting the state
        self.state = .answeringSpeech
        
        // initializing audio player
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer.isMeteringEnabled = true
        audioPlayer.delegate = self
        audioPlayer.play()   // plays the audio
        
        // Siri animation timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { [ unowned self]_ in
            guard self.audioPlayer != nil else {return}
            self.audioPlayer.updateMeters()
            
            let power = min(1, max(0, 1 - abs( Double(self.audioPlayer.averagePower(forChannel: 0)) / 150 )  ))
            
            self.audioPower = power
            
        })
        
    }
    
    // when user cancels the audio recording
    func cancelRecording(){
        
        // reset the values
        resetValue()
        state = .idle
        
    }
    
    func cancelProcessingTask(){
        
        // cancel the processing of the task
        processingSpeechTask?.cancel()
        
        // set the variable to nil
        processingSpeechTask = nil
        
        // reset all the values to clear the app changes
        resetValue()
        
        // after canceling the process app will be in idlle state
        state = .idle
        
    }
    
    // if recorder fails
    func audioRecorderDidFinishRecording( _ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        // reset the values if the recording of audio fails
        if !flag{
            resetValue()
            state = .idle
        }
    }
    
    // After the chatgpt finishes the response
    func audioPlayerDidFinishPlaying( _ player: AVAudioPlayer, successfully flag: Bool)
    {
        // reset all the values
        resetValue()
        state = .idle
    
    }
    
    // resetting all the properties to clear the failures once the processing & using of app is done
    func resetValue(){
        
        audioPower = 0
        prevAudioPower = nil
        audioRecorder?.stop()
        
        audioRecorder = nil
        audioPlayer?.stop()
        audioPlayer = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
}
