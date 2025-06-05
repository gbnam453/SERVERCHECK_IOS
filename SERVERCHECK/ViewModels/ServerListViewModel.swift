// ViewModels/ServerListViewModel.swift

import Foundation
import Combine

class ServerListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var groups: [Group] = []
    @Published var lastChecked: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let storageKey = "server_groups"
    
    init() {
        loadGroups()
    }
    
    // MARK: - 서버 추가
    
    /// 첫 번째 그룹에 서버 추가 (그룹이 없으면 “Group 1” 생성)
    func addServer(
        name: String,
        type: CheckType,
        host: String,
        port: UInt16?,
        toGroupIndex idx: Int
    ) {
        let newServer = Server(name: name, host: host, port: port, type: type)
        if groups.isEmpty {
            let g1 = Group(name: "Group 1", servers: [newServer])
            groups.append(g1)
        } else if idx >= 0 && idx < groups.count {
            groups[idx].servers.append(newServer)
        } else {
            groups[0].servers.append(newServer)
        }
        saveGroups()
        checkAll()
    }

    // MARK: - 서버 수정
    
    func updateServer(_ server: Server) {
        for gi in groups.indices {
            if let si = groups[gi].servers.firstIndex(where: { $0.id == server.id }) {
                groups[gi].servers[si] = server
                break
            }
        }
        saveGroups()
    }
    
    // MARK: - 서버 삭제
    
    func deleteServer(_ id: UUID) {
        for gi in groups.indices {
            if let si = groups[gi].servers.firstIndex(where: { $0.id == id }) {
                groups[gi].servers.remove(at: si)
                if groups[gi].servers.isEmpty {
                    groups.remove(at: gi)
                }
                break
            }
        }
        saveGroups()
    }
    
    // MARK: - 그룹 이름 수정
    
    func renameGroup(at index: Int, newName: String) {
        guard groups.indices.contains(index) else { return }
        groups[index].name = newName
        saveGroups()
    }
    
    // MARK: - 그룹 순서 변경
    
    func moveGroup(fromOffsets: IndexSet, toOffset: Int) {
        groups.move(fromOffsets: fromOffsets, toOffset: toOffset)
        saveGroups()
    }
    
    // MARK: - 서버 순서 변경 (그룹 내)
    
    func moveServer(in group: Group, fromOffsets: IndexSet, toOffset: Int) {
        guard let gi = groups.firstIndex(where: { $0.id == group.id }) else { return }
        groups[gi].servers.move(fromOffsets: fromOffsets, toOffset: toOffset)
        saveGroups()
    }
    
    // MARK: - UserDefaults 저장/불러오기
    
    func saveGroups() {
        if let data = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    private func loadGroups() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([Group].self, from: data) {
            groups = saved
        } else {
            groups = []
        }
    }
    
    // MARK: - 헬스체크 (Ping/TCP/HTTP)
    
    func checkAll() {
        let dispatchGroup = DispatchGroup()
        let now = DateFormatter()
        now.dateFormat = "yyyy-MM-dd HH:mm:ss '기준'"

        for group in groups {
            for server in group.servers {
                dispatchGroup.enter()
                NetworkChecker.check(server: server) { [weak self] ok, rtt, err, code in
                    DispatchQueue.main.async {
                        guard let self = self else {
                            dispatchGroup.leave()
                            return
                        }

                        // 현재 배열에서 “서버 ID”를 찾아서, 그 위치(giCurrent, siCurrent)에 업데이트
                        guard
                            let giCurrent = self.groups.firstIndex(where: { $0.id == group.id }),
                            let siCurrent = self.groups[giCurrent].servers.firstIndex(where: { $0.id == server.id })
                        else {
                            dispatchGroup.leave()
                            return
                        }

                        var updated = server
                        if ok {
                            updated.status = .up
                            updated.responseTime = rtt
                            updated.responseError = nil
                            updated.responseStatusCode = code
                        } else {
                            updated.status = .down
                            updated.responseTime = rtt
                            updated.responseError = err
                            updated.responseStatusCode = code
                        }

                        self.groups[giCurrent].servers[siCurrent] = updated
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.lastChecked = now.string(from: Date())
            self.saveGroups()
        }
    }
}
