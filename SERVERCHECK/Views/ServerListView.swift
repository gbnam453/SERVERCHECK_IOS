// Views/ServerListView.swift

import SwiftUI
import Combine

struct ServerListView: View {
    @StateObject private var vm = ServerListViewModel()
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var editingServer: Server?
    @State private var duplicatingServer: Server?

    // AppStorage에 저장된 새로고침 간격 (초 단위)
    @AppStorage("refreshInterval") private var refreshInterval: Double = 60.0

    // 남은 시간(초)을 표시할 상태 변수
    @State private var remainingTime: Double = 0

    // 타이머 퍼블리셔: 1초마다 발행
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if vm.groups.isEmpty {
                    VStack(spacing: 8) {
                        Spacer()
                        Text("등록된 서버가 없어요")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("우측 상단 + 버튼을 눌러 추가할 수 있어요")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // 기준 시간: 리스트 왼쪽 위
                            HStack {
                                Text(vm.lastChecked)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)

                            // 그룹 및 서버 카드 목록
                            ForEach(vm.groups.indices, id: \.self) { gi in
                                let group = vm.groups[gi]

                                // 그룹 헤더
                                HStack {
                                    Button {
                                        vm.groups[gi].isExpanded.toggle()
                                        vm.saveGroups()
                                    } label: {
                                        Image(
                                            systemName: group.isExpanded
                                                ? "chevron.down"
                                                : "chevron.right"
                                        )
                                        .foregroundColor(.primary)
                                        .padding(.leading, 16)
                                        .padding(.trailing, 4)
                                    }

                                    Text(group.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .background(Color(.systemGroupedBackground))

                                if group.isExpanded {
                                    LazyVStack(spacing: 12) {
                                        ForEach(group.servers) { server in
                                            ServerCardView(server: server)
                                                .contentShape(Rectangle())
                                                .contextMenu {
                                                    Button("수정") {
                                                        editingServer = server
                                                    }
                                                    Button("복제") {
                                                        duplicatingServer = server
                                                    }
                                                    Button(role: .destructive) {
                                                        vm.deleteServer(server.id)
                                                    } label: {
                                                        Label("삭제", systemImage: "trash")
                                                    }
                                                }
                                                .padding(.horizontal)
                                        }
                                    }
                                    .padding(.bottom, 8)
                                }
                            }
                        }
                        .padding(.top, 0)
                    }
                }
            }
            .navigationTitle("서버췍")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // 좌측: 새로고침 버튼 + 남은 시간
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if !vm.groups.isEmpty {
                        Button {
                            manualRefresh()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        if abs(refreshInterval - 0.5) < 0.0001 {
                            Text("실시간")
                                .font(.subheadline.monospacedDigit())
                                .foregroundColor(.secondary)
                        } else if refreshInterval > 0 {
                            Text("\(Int(max(0, remainingTime.rounded())))초")
                                .font(.subheadline.monospacedDigit())
                                .foregroundColor(.secondary)
                        }
                    }
                }
                // 우측: 서버 추가 및 설정 버튼
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .onAppear {
                startCountdown()
            }
            .onReceive(timer) { _ in
                tickCountdown()
            }
            // 서버 추가/수정/복제 모달
            .sheet(isPresented: $showingAdd) {
                AddEditServerView(vm: vm)
            }
            .sheet(item: $editingServer) { server in
                AddEditServerView(vm: vm, server: server)
            }
            .sheet(item: $duplicatingServer) { server in
                AddEditServerView(vm: vm, server: server, isDuplicate: true)
            }
            // 설정 모달
            .sheet(isPresented: $showingSettings) {
                SettingsView(vm: vm)
            }
            // 당겨서 새로고침 시 수동 새로고침 동작
            .refreshable {
                manualRefresh()
            }
        }
    }

    // MARK: - 카운트다운 시작
    private func startCountdown() {
        guard refreshInterval > 0 else {
            remainingTime = 0
            return
        }
        remainingTime = refreshInterval
    }

    // MARK: - 타이머 틱마다 호출
    private func tickCountdown() {
        guard refreshInterval > 0 else {
            remainingTime = 0
            return
        }
        if remainingTime > 0 {
            remainingTime -= 1
        }
        if remainingTime <= 0 {
            vm.checkAll()
            remainingTime = refreshInterval
        }
    }

    // MARK: - 수동 새로고침
    private func manualRefresh() {
        vm.checkAll()
        if refreshInterval > 0 {
            remainingTime = refreshInterval
        }
    }
}
