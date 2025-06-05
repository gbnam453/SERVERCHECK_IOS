// Models/CheckType.swift

import Foundation

enum CheckType: String, CaseIterable, Identifiable, Codable {
    case ping = "PING"
    case tcp  = "TCP"
    case http = "HTTP"
    
    var id: String { rawValue }
}
