// Views/AddEditServerView.swift

import SwiftUI

struct AddEditServerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: ServerListViewModel

    @State private var name: String
    @State private var type: CheckType
    @State private var host: String
    @State private var portString: String
    private let editingServer: Server?

    init(vm: ServerListViewModel, server: Server? = nil) {
        self.vm = vm
        self.editingServer = server
        _type = State(initialValue: server?.type ?? .ping)
        _name = State(initialValue: server?.name ?? "")
        _host = State(initialValue: server?.host ?? "")
        _portString = State(initialValue: server?.port.map(String.init) ?? "")
    }

    private var port: UInt16? {
        type == .tcp ? UInt16(portString) : nil
    }

    private var isSaveDisabled: Bool {
        name.isEmpty || host.isEmpty || (type == .tcp && port == nil)
    }

    private func saveServer() {
        if var srv = editingServer {
            srv.name = name
            srv.type = type
            srv.host = host
            srv.port = port
            vm.updateServer(srv)
        } else {
            vm.addServer(name: name, type: type, host: host, port: port)
        }
        dismiss()
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1. 체크 유형 선택(segmented control)
                Picker("체크 유형", selection: $type) {
                    ForEach(CheckType.allCases) { ct in
                        Text(ct.rawValue).tag(ct)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top)
                .padding(.horizontal)

                // 2. 서버 정보 입력 폼
                Form {
                    Section(header: Text(editingServer == nil ? "서버 추가" : "서버 수정")) {
                        TextField("이름", text: $name)
                        TextField("호스트 (예: example.com)", text: $host)
                            .keyboardType(.URL)
                        if type == .tcp {
                            TextField("포트", text: $portString)
                                .keyboardType(.numberPad)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))

                // 3. 버전 표시
                Text("1.2.0 gbnam")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(editingServer == nil ? "서버 추가" : "서버 수정")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: saveServer)
                        .disabled(isSaveDisabled)
                }
            }
        }
    }
}
