//
//  ContentView.swift
//  MyAIAssistant
//
//  Created by Snehal Chavan on 7/11/25.
//

import SwiftUI
import SiriWaveView // display siriwave 

struct ContentView: View {
    
    @State var vm = ViewModel()
    
    // state to control the animation
    @State var isSymbolAnimating = false
    
    var body: some View {
        
        VStack(spacing: 15){
            
            // App title
            Text(" My AI Assistant")
                .font(.title2)
            
            
            Spacer()
            SiriWaveView(power: $vm.audioPower)
                //.power(power: vm.audioPower)
                .opacity(vm.siriWaveFromOpacity)
                .frame(height: 255)
                .overlay { overLayView }
            
            Spacer()
            
            
            switch vm.state{
                
            // button to cancel the recording
            case .recordingSpeech:
                cancelRecordingButton
                
            case .processingSpeech, .answeringSpeech:
                cancelButton
                
            default: EmptyView()
            }
            
            
            
            Picker(" Select the voice: ", selection: $vm.selectedVoice)
            {
                ForEach(VoiceType.allCases, id: \.self)
                {
                    Text($0.rawValue).id($0)
                }
            }
            .pickerStyle(.segmented)
            .disabled(!vm.isIdle)
            
            if case let .error(error) = vm.state{
                
                Text( error.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .lineLimit(2)
            }
            
        }
        .padding()
    }
    
    @ViewBuilder
    var overLayView: some View {
        
        switch vm.state{
            
        case .idle, .error:
                
            startCaptureButton
            
        case .processingSpeech:
            // display image when the text is processing the audio input in openAI api
            Image(systemName: "brain")
                .symbolEffect(.bounce.up.byLayer,
                              options: .repeating, value: isSymbolAnimating)
                .font(.system(size: 125))
                .onAppear{ isSymbolAnimating = true }
                .onDisappear { isSymbolAnimating = false }
            
        default: EmptyView()
        }
    }
    
    // button to start recording the audio
    var startCaptureButton: some View {
        
        Button{
            
            vm.startCaptureAudio()
        }
        label: {
            
            Image(systemName: "mic.circle")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 125))
            
        }.buttonStyle(.borderless)
        
    }
    
    // defining the cancelrecording button
    var cancelRecordingButton: some View{
        
        Button(role: .destructive) {
            
            vm.cancelRecording()
        }
        label: {
            // displays the symbol for stopping the recording
            Image( systemName: "xmark.circle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.red)
                .font(.system(size: 44))
        }.buttonStyle(.borderless)
    }
    
    // defining cancel button
    var cancelButton: some View{
        
        Button(role: .destructive) {
            
            vm.cancelProcessingTask()
        }
        label: {
            // displays the symbol for cancel the recording
            Image( systemName: "stop.circle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.red)
                .font(.system(size: 44))
        }.buttonStyle(.borderless)
    }
}





#Preview("Idle") {
    ContentView()
}

#Preview("Recording the speech") {
    
    let vm  = ViewModel()
    
    vm.state = .recordingSpeech
    vm.audioPower = 0.2
    
    return ContentView(vm: vm)
}

#Preview("Processing the speech") {
    
    let vm  = ViewModel()
    
    vm.state = .processingSpeech
    
    return ContentView(vm: vm)
}

#Preview("Answering the query") {
    
    let vm  = ViewModel()
    
    vm.state = .answeringSpeech
    vm.audioPower = 0.3
    
    return ContentView(vm: vm)
}

#Preview("Error") {
    
    let vm  = ViewModel()
    
    // vm.state = .error(" Error has occured" as! Error)
    
    // vm.state = .error("Error has occured")
    


    vm.state = .error(NSError(domain: "", code: -1,
                                      userInfo: [NSLocalizedDescriptionKey: "Error has occurred"]))
    return ContentView(vm: vm)

    // ContentView(vm: vm)
    
    
}
