//
//  OpenAIStreaming.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/20/25.
//

import Foundation

protocol OpenAIStreamingDelegate {
    func streamUpdate(_ body: String) -> Void
    func streamDone(_ body: String) -> Void
}


class OpenAIStreaming: NSObject, URLSessionDataDelegate {
    var delegate: OpenAIStreamingDelegate?
    private var urlSession: URLSession!
    private var task: URLSessionDataTask?
    private let debug = false
    
    var active = false
    var body = ""
    var done = false
    
    override init() {
        super.init()
        urlSession = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: self,
            delegateQueue: nil
        )
    }
    
    func streamThread(_ thread: Thread, model: OpenAI.Model.ID) {
        streamChatCompletion(
            thread.messages.map({
                Message(
                    role: $0.sender == .user ? "user" : "assistant",
                    content: $0.text
                )
            }),
            model: model
        )
    }
    
    private func streamChatCompletion(
        _ messages: [Message],
        model: OpenAI.Model.ID
    ) {
        done = false
        active = true
        body = ""
        
        var request = OpenAI.shared.apiRequest(
            "/v1/chat/completions",
            method: "POST"
        )
        
        let azReq = ChatCompletionRequest(model: model, messages: messages)
        let body = try! JSONEncoder().encode(azReq)
        request.httpBody = body
        
        task = urlSession.dataTask(with: request)
        task?.resume()
    }
    
    func stopListening() {
        task?.cancel()
        active = false
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        if let dataString = String(data: data, encoding: .utf8) {
            let lines = dataString.split(separator: "\n")
            for line in lines {
                if line.hasPrefix("data: ") {
                    let jsonString = line.replacingOccurrences(
                        of: "data: ",
                        with: ""
                    )
                    if jsonString == "[DONE]" {
                        active = false
                        done = true
                        delegate?.streamDone(body)
                        break
                    } else if let json = jsonString.data(using: .utf8) {
                        do {
                            if debug {
                                print(json)
                            }
                            let resp = try JSONDecoder().decode(
                                ChatCompletionResponse.self,
                                from: json
                            )
                            if let content = resp.choices.first?.delta.content {
                                body = body + content
                                delegate?.streamUpdate(body)
                            }
                        } catch {
                            print("Failed to decode response: \(error)")
                        }
                    }
                }
            }
        }
    }
}

extension OpenAIStreaming {
    struct ChatCompletionResponse: Decodable {
        let choices: [Choice]
    }
    
    struct Choice: Decodable {
        let delta: Delta
    }
    
    struct Delta: Decodable {
        let content: String?
        
    }
    
    struct Message: Encodable {
        let role: String
        let content: String
    }
    
    struct ChatCompletionRequest: Encodable {
        var model: OpenAI.Model.ID
        var messages: [Message]
        var temperature = 1.0
        var stream = true
    }
}
