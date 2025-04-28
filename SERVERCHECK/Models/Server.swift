// Models/Server.swift

import Foundation

enum CheckType: String, CaseIterable, Codable, Identifiable {
    case ping = "Ping"
    case tcp  = "TCP"
    case http = "HTTP"
    var id: String { rawValue }
}

enum ServerStatus: String, Codable {
    case checking, up, down
}

struct Server: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: CheckType
    var host: String
    var port: UInt16?
    var status: ServerStatus
    var responseTime: Double?
    var responseError: String?
    var responseStatusCode: Int?

    init(
        id: UUID = .init(),
        name: String,
        type: CheckType = .ping,
        host: String,
        port: UInt16? = nil,
        status: ServerStatus = .checking,
        responseTime: Double? = nil,
        responseError: String? = nil,
        responseStatusCode: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.host = host
        self.port = port
        self.status = status
        self.responseTime = responseTime
        self.responseError = responseError
        self.responseStatusCode = responseStatusCode
    }
}
