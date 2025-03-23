//
//  FontSize.swift
//  CocoaChat
//
//  Created by Matt Overholt on 3/2/25.
//

import AppKit

enum FontSize {
    case normal
    case smaller1, smaller2, smaller3
    case larger1, larger2, larger3
    
    var value: CGFloat {
        let base = NSFont.systemFontSize
        let step = base * 0.20
        switch self {
        case .normal: return base
        case .larger1:
            return base + step
        case .larger2:
            return base + step * 2
        case .larger3:
            return base + step * 3
        case .smaller1:
            return base - step
        case .smaller2:
            return base - step * 2
        case .smaller3:
            return base - step * 3
        }
    }
    
    var larger: FontSize {
        switch self {
        case .normal:
            return .larger1
        case .larger1:
            return .larger2
        case .larger2:
            return .larger3
        case .larger3:
            return .larger3
        case .smaller1:
            return .normal
        case .smaller2:
            return .smaller1
        case .smaller3:
            return .smaller2
        }
    }
    
    var smaller: FontSize {
        switch self {
        case .normal:
            return .smaller1
        case .larger1:
            return .normal
        case .larger2:
            return .larger1
        case .larger3:
            return .larger2
        case .smaller1:
            return .smaller2
        case .smaller2:
            return .smaller3
        case .smaller3:
            return .smaller3
        }
    }
}
