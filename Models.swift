//
//  Models.swift
//  MyAIAssistant
//
//  Created by Snehal Chavan on 7/12/25.
//

import Foundation

enum VoiceType: String, Codable, Hashable, Sendable, CaseIterable{
    
    // cases from openAI api
    case alloy
    case echo
    case fable
    case onyx
    case nova
    case shimmer
}

enum VoiceChatState{
    
    case idle
    case recordingSpeech
    case processingSpeech
    case answeringSpeech
    case error(Error)
}
