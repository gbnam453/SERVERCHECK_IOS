// Models/Group.swift

import Foundation

struct Group: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var servers: [Server]
    
    /// 뷰에서 펼치기/접기 토글용
    var isExpanded: Bool = true

    init(
        id: UUID = UUID(),
        name: String,
        servers: [Server] = []
    ) {
        self.id = id
        self.name = name
        self.servers = servers
    }
}
