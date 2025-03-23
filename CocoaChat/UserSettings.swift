//
//  UserSettings.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/18/25.
//

import Cocoa

class UserSettings {
    static let shared = UserSettings()
    
    init() {
        model = UserSettings.load()
    }
    
    struct Model: Codable {
        var apiKey: String? = nil
        var defaultModelId = "gpt-4o"
    }
    
    private(set) var model: Model
    
    func setApiKey(_ key: String) {
        model.apiKey = key
        save()
    }
    
    func setDefaultModelId(_ id: String) {
        model.defaultModelId = id
        save()
    }
    
    private static var storageKey = "user-settings"
    
    private func save() {
        if let data = try? JSONEncoder().encode(model) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
    
    private static func load() -> Model {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            if let model = try? JSONDecoder().decode(Model.self, from: data) {
                return model
            }
        }
        return Model()
    }
}
