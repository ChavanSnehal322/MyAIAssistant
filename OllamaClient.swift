//
//  OllamaClient.swift
//  MyAIAssistant
//
//  Created by Snehal Chavan on 8/16/25.
//

import Foundation

struct OllamaClient {
    let baseURL = URL(string: "http://localhost:11434")! // default Ollama port

    /// Generate a chat completion
    func chat(model: String, messages: [[String: String]]) async throws -> String {
        let url = baseURL.appendingPathComponent("api/chat")

        let body: [String: Any] = [
            "model": model,
            "messages": messages
        ]

        let data = try JSONSerialization.data(withJSONObject: body)
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = data
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (respData, _) = try await URLSession.shared.data(for: req)
        let json = try JSONSerialization.jsonObject(with: respData) as? [String: Any]

        if let msg = (json?["message"] as? [String: Any])?["content"] as? String {
            return msg
        } else {
            throw NSError(domain: "OllamaClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "No response text"])
        }
    }

}
