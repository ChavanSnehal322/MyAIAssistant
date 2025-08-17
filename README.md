# MyAIAssistant

MyAIAssistant is a SwiftUI-based AI voice assistant for iOS and macOS. It allows users to speak naturally, transcribes their speech using Apple's Speech framework, sends the transcribed text to an AI model powered by Ollama, and responds with synthesized speech using AVFoundation. The app also features a Siri-like waveform animation to visualize audio input.

----------------------------------------------------------------------------------------------------------------------------------------------------
** Features **

- Voice Input & Recording
Record user speech with automatic silence detection to stop recording when the user finishes talking.

- Speech-to-Text
Transcribes audio to text using Apple's SFSpeechRecognizer.

- AI Response via Ollama
Sends transcribed text to an AI model (llama2:latest) and receives a response.

- Text-to-Speech
Uses AVSpeechSynthesizer to vocalize AI responses.

- Waveform Animation
Displays a Siri-style waveform animation representing audio power levels in real-time.

- Custom Voice Options
Supports multiple voices for the assistant (alloy, echo, fable, onyx, nova, shimmer).

- Cancel Operations
Users can cancel recording or processing tasks at any time.

- Cross-Platform
Works on both iOS and macOS with adaptive window sizing and interface adjustments

----------------------------------------------------------------------------------------------------------------------------------------

** Setup Instructions ** 

1] Clone the repository
  
  > git clone https://github.com/<your-username>/MyAI-Assistant.git
  > cd MyAI-Assistant

2] Open in Xcode
  open MyAI-Assistant.xcodeproj

3] Install Dependencies
  - The project uses SiriWaveView for waveform animations. Add via Swift Package Manager.

4] Configure Permissions

  Ensure the following keys are present in your Info.plist:

    <key>NSMicrophoneUsageDescription</key>
    <string>Talk with your AI assistant</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>Transcribe your speech into text</string>

5] Run Ollama Server

  > ollama serve

6] Build and Run the App after selecting the desired simulator/device and hit Run.

------------------------------------------------------------------------------------------------------------------

** Working of project ***

1] Record Audio

  - User taps the microphone button.

  - Audio is recorded and the waveform animates in real-time.

2] Transcribe Audio

  - SFSpeechRecognizer transcribes the recording to text asynchronously.

3] Chat with AI

  - Transcribed text is sent to Ollama using the llama2:latest model.

  - The AI responds with a textual answer.

4] Speak the Response

  - The response is converted to speech using AVSpeechSynthesizer.

  - Waveform continues to animate during playback.


