// Models/Server.swift

import Foundation

struct Server: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var host: String
    var port: UInt16?
    var type: CheckType

    // Health check 상태를 저장할 프로퍼티들
    enum Status: String, Codable {
        case up, down, unknown
    }
    var status: Status = .unknown

    /// 마지막으로 응답을 받은 시각(ms)
    var responseTime: Double? = nil

    /// Ping/TCP/HTTP 에러 메시지 (예: 네트워크 오류)
    var responseError: String? = nil

    /// HTTP 상태 코드(404, 500 등)가 있는 경우 해당 값
    var responseStatusCode: Int? = nil

    init(
        id: UUID = UUID(),
        name: String,
        host: String,
        port: UInt16?,
        type: CheckType
    ) {
        self.id = id
        self.name = name
        self.host = host
        self.port = port
        self.type = type
    }
}
