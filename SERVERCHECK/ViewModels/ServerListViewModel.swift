// ViewModels/ServerListViewModel.swift

import Foundation
import Combine
import Network

@MainActor
class ServerListViewModel: ObservableObject {
    @Published var servers: [Server] = []
    @Published var lastChecked: String = ""

    init() {
        loadServers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkAll()
        }
    }

    // MARK: - Persistence

    func loadServers() {
        if let data = UserDefaults.standard.data(forKey: "servers"),
           let saved = try? JSONDecoder().decode([Server].self, from: data) {
            servers = saved
        }
    }

    func saveServers() {
        if let data = try? JSONEncoder().encode(servers) {
            UserDefaults.standard.set(data, forKey: "servers")
        }
    }

    // MARK: - CRUD

    /// 새로운 서버를 추가합니다.
    func addServer(name: String,
                   type: CheckType,
                   host: String,
                   port: UInt16?) {
        let newServer = Server(
            name: name,
            type: type,
            host: host,
            port: port
        )
        servers.append(newServer)
        saveServers()
        checkAll()
    }

    /// 기존 서버를 수정합니다.
    func updateServer(_ updated: Server) {
        guard let idx = servers.firstIndex(where: { $0.id == updated.id }) else { return }
        servers[idx] = updated
        saveServers()
        checkAll()
    }

    /// 서버를 삭제합니다.
    func deleteServer(_ id: UUID) {
        servers.removeAll { $0.id == id }
        saveServers()
    }

    // MARK: - Health Checks

    /// 모든 서버를 검사합니다.
    func checkAll() {
        lastChecked = Self.dateFormatter.string(from: Date()) + " 기준"
        for idx in servers.indices {
            servers[idx].status = .checking
            servers[idx].responseTime = nil
            servers[idx].responseError = nil
            servers[idx].responseStatusCode = nil

            let srv = servers[idx]
            NetworkChecker.check(server: srv) { [weak self] ok, time, err, code in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.servers[idx].status = ok ? .up : .down
                    self.servers[idx].responseTime = time
                    self.servers[idx].responseError = err
                    self.servers[idx].responseStatusCode = code
                    self.saveServers()
                }
            }
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
}
