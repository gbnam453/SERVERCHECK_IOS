// Views/ServerListView.swift

import SwiftUI

struct ServerListView: View {
    @StateObject private var vm = ServerListViewModel()
    @State private var showingAdd = false
    @State private var showingOrder = false
    @State private var editingServer: Server?

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if vm.servers.isEmpty {
                    // 빈 상태 안내
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
                    // 서버 리스트
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            // 마지막 확인 시간
                            Text(vm.lastChecked)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .padding(.top, 8)

                            // 카드 뷰
                            ForEach(vm.servers) { server in
                                ServerCardView(server: server)
                                    .contentShape(Rectangle())
                                    .contextMenu {
                                        Button("수정") {
                                            editingServer = server
                                        }
                                        Button(role: .destructive) {
                                            vm.deleteServer(server.id)
                                        } label: {
                                            Label("삭제", systemImage: "trash")
                                        }
                                    }
                                    .padding(.horizontal)
                            }

                            Spacer(minLength: 20)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("서버췍")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // 서버가 있을 때만 '정렬' 버튼
                if !vm.servers.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingOrder = true
                        } label: {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                        }
                    }
                }
                // '새로고침' (서버 있을 때만) & '추가'
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !vm.servers.isEmpty {
                        Button {
                            vm.checkAll()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                vm.checkAll()
            }
            .sheet(isPresented: $showingAdd) {
                AddEditServerView(vm: vm)
            }
            .sheet(isPresented: $showingOrder) {
                ServerOrderView(vm: vm)
            }
            .sheet(item: $editingServer) { server in
                AddEditServerView(vm: vm, server: server)
            }
        }
    }
}
