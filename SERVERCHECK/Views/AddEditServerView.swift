// Views/AddEditServerView.swift

import SwiftUI

struct AddEditServerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: ServerListViewModel

    // 입력 필드 상태
    @State private var name: String
    @State private var type: CheckType
    @State private var host: String
    @State private var portString: String

    // 수정 모드인 기존 서버, 복제 모드 여부
    private let editingServer: Server?
    private let isDuplicate: Bool

    // 그룹 선택 관련 상태
    @State private var selectedGroupIndex: Int = 0
    @State private var newGroupName: String = ""
    @State private var showingNewGroupAlert = false
    @State private var priorGroupIndex: Int = 0

    init(vm: ServerListViewModel, server: Server? = nil, isDuplicate: Bool = false) {
        self.vm = vm
        self.editingServer = server
        self.isDuplicate = isDuplicate

        // 입력 필드 초기값
        _name = State(initialValue: server?.name ?? "")
        _type = State(initialValue: server?.type ?? .ping)
        _host = State(initialValue: server?.host ?? "")
        _portString = State(initialValue: server?.port.map(String.init) ?? "")

        // 편집 중 서버가 있으면, 속한 그룹 인덱스를 찾아 초기값으로
        if let srv = server,
           let gi = vm.groups.firstIndex(where: { $0.servers.contains(where: { $0.id == srv.id }) }) {
            _selectedGroupIndex = State(initialValue: gi)
            _priorGroupIndex    = State(initialValue: gi)
        } else {
            // 서버 미편집 상태라면, 기본으로 0
            _selectedGroupIndex = State(initialValue: 0)
            _priorGroupIndex    = State(initialValue: 0)
        }
    }

    // portString을 UInt16?로 변환
    private var port: UInt16? {
        guard type == .tcp, let p = UInt16(portString) else { return nil }
        return p
    }

    // 저장 버튼 활성/비활성 조건
    private var isSaveDisabled: Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty { return true }
        if host.trimmingCharacters(in: .whitespaces).isEmpty { return true }
        if type == .tcp && port == nil { return true }
        return false
    }

    // 실제 vm.groups 배열을 건드리지 않고, Picker에 보여줄 그룹 이름 리스트 반환
    private var pickerOptions: [String] {
        if vm.groups.isEmpty {
            // 그룹이 하나도 없으면, 인덱스 0: "My Servers", 인덱스 1: "새 그룹 만들기"
            return ["My Servers", "새 그룹 만들기"]
        } else {
            // 기존 그룹 + "새 그룹 만들기"
            return vm.groups.map { $0.name } + ["새 그룹 만들기"]
        }
    }

    private func saveServer() {
        // 1) 선택된 인덱스가 "새 그룹 만들기"일 때
        let creatingNewIndex = pickerOptions.count - 1

        var targetGroupIndex: Int

        if vm.groups.isEmpty {
            // 그룹이 없던 상태에서
            if selectedGroupIndex == 0 {
                // “My Servers” 선택 → 새로 그룹 생성
                let newGroup = Group(name: "My Servers")
                vm.groups.append(newGroup)
                vm.saveGroups()
                targetGroupIndex = 0
            } else {
                // “새 그룹 만들기” 선택 → newGroupName으로 생성
                let trimmed = newGroupName.trimmingCharacters(in: .whitespaces)
                let groupName = trimmed.isEmpty ? "My Servers" : trimmed
                let newGroup = Group(name: groupName)
                vm.groups.append(newGroup)
                vm.saveGroups()
                targetGroupIndex = 0
            }
        } else {
            // 기존 그룹이 하나 이상 있는 상태
            if selectedGroupIndex < vm.groups.count {
                // 기존 그룹 선택
                targetGroupIndex = selectedGroupIndex
            } else {
                // “새 그룹 만들기” 선택 → newGroupName으로 생성
                let trimmed = newGroupName.trimmingCharacters(in: .whitespaces)
                let groupName = trimmed.isEmpty ? "My Servers" : trimmed
                let newGroup = Group(name: groupName)
                vm.groups.append(newGroup)
                vm.saveGroups()
                targetGroupIndex = vm.groups.count - 1
            }
        }

        if let srv = editingServer, !isDuplicate {
            // “수정” 모드
            if let originalGI = vm.groups.firstIndex(where: { $0.servers.contains(where: { $0.id == srv.id }) }),
               let originalSI = vm.groups[originalGI].servers.firstIndex(where: { $0.id == srv.id }) {

                // 원래 그룹에서 삭제
                vm.groups[originalGI].servers.remove(at: originalSI)

                // 새 Server 객체 만들기
                var updated = srv
                updated.name = name
                updated.type = type
                updated.host = host
                updated.port = port

                // 원래 그룹이 빈 상태라면 삭제
                if vm.groups[originalGI].servers.isEmpty {
                    vm.groups.remove(at: originalGI)
                    if originalGI < targetGroupIndex {
                        targetGroupIndex -= 1
                    }
                }

                // 수정 서버를 목표 그룹에 추가
                vm.groups[targetGroupIndex].servers.append(updated)
                vm.saveGroups()
            }
        } else {
            // “추가” 또는 “복제” 모드
            vm.addServer(
                name: name,
                type: type,
                host: host,
                port: port,
                toGroupIndex: targetGroupIndex
            )
        }

        dismiss()
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1. 체크 유형 Segmented Picker
                Picker("체크 유형", selection: $type) {
                    ForEach(CheckType.allCases) { ct in
                        Text(ct.rawValue).tag(ct)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top)
                .padding(.horizontal)

                // 2. 서버 정보 입력 Form
                Form {
                    Section(header: Text(
                        isDuplicate
                            ? "서버 복제"
                            : (editingServer == nil ? "서버 추가" : "서버 수정")
                    )) {
                        TextField("이름", text: $name)
                        TextField("호스트 (예: example.com)", text: $host)
                            .keyboardType(.URL)
                        if type == .tcp {
                            TextField("포트 (숫자만)", text: $portString)
                                .keyboardType(.numberPad)
                        }
                    }

                    // 3. 그룹 선택 및 “새 그룹 만들기”
                    Section(header: Text("그룹")) {
                        Picker("그룹 선택", selection: $selectedGroupIndex) {
                            ForEach(pickerOptions.indices, id: \.self) { idx in
                                Text(pickerOptions[idx])
                                    .foregroundColor(.primary)
                                    .tag(idx)
                            }
                        }
                        .onChange(of: selectedGroupIndex) { newValue in
                            if newValue == pickerOptions.count - 1 {
                                // “새 그룹 만들기” 선택 시 Alert 띄우기
                                selectedGroupIndex = priorGroupIndex
                                showingNewGroupAlert = true
                            } else {
                                priorGroupIndex = newValue
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(
                isDuplicate
                    ? "서버 복제"
                    : (editingServer == nil ? "서버 추가" : "서버 수정")
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: saveServer)
                        .disabled(isSaveDisabled)
                }
            }
            // “새 그룹 이름 입력” Alert
            .alert("새 그룹 이름 입력", isPresented: $showingNewGroupAlert) {
                TextField("그룹 이름", text: $newGroupName)
                Button("생성") {
                    let trimmed = newGroupName.trimmingCharacters(in: .whitespaces)
                    let groupName = trimmed.isEmpty ? "My Servers" : trimmed
                    // 이곳에서 새 그룹을 실제로 추가하고 선택 인덱스를 업데이트
                    let newGroup = Group(name: groupName)
                    vm.groups.append(newGroup)
                    vm.saveGroups()
                    selectedGroupIndex = vm.groups.count - 1
                    priorGroupIndex = selectedGroupIndex
                    newGroupName = ""
                }
                Button("취소", role: .cancel) {
                    newGroupName = ""
                }
            } message: {
                Text("추가할 그룹 이름을 입력하세요.")
            }
        }
    }
}
