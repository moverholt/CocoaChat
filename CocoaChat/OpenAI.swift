//
//  OpenAI.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/18/25.
//

import Cocoa

class OpenAI {
    static let shared = OpenAI()
    
    private(set) var models: [Model]?
    private let endpoint = "https://api.openai.com"
    
    enum ClientError: Error {
        case runtimeError(String)
    }
    
    struct Model: Decodable, Identifiable, Hashable {
        let id: String
        let object: String
        let created: Int
        let owned_by: String
    }
    
    struct ModelsResponse: Decodable {
        let object: String
        let data: [Model]
    }
    
    private func apiUrl(_ path: String) -> URL {
        return URL(string: "\(endpoint)\(path)")!
    }
    
    private var useableModekIds: [String] {
        [
            "gpt-4",
            "gpt-4o",
            "gpt-4.5-preview",
            "o1",
            "o3-mini"
        ]
    }
    
    func models() async -> Result<[Model], Error> {
        if let models = self.models {
            return .success(models)
        }
        let request = apiRequest("/v1/models")
        let resp = await makeApiRequest(request)
        switch resp {
        case .success(let data):
            if let resp = try? JSONDecoder().decode(
                ModelsResponse.self, from: data
            ) {
                let models = resp.data.sorted(by: { $0.id < $1.id }).filter({
                    useableModekIds.contains($0.id)
                })
                self.models = models
                print("Models found: \(models.count)")
                return .success(models)
            }
            return .failure(
                ClientError.runtimeError("Failed to decode models")
            )
        case .failure(let err):
            return .failure(err)
        }
    }
    
    func apiRequest(_ path: String, method: String = "GET") -> URLRequest {
        let url = apiUrl(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.setValue(
            "Bearer \(UserSettings.shared.model.apiKey ?? "no-key")",
            forHTTPHeaderField: "Authorization"
        )
        return request
    }
    
    private func makeApiRequest(
        _ req: URLRequest
    ) async -> Result<Data, Error> {
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let httpResponse = resp as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return .failure(URLError(.badServerResponse))
            }
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
    
}


