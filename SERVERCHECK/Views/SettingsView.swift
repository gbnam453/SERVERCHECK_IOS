// Views/SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: ServerListViewModel
    @Environment(\.dismiss) private var dismiss

    @AppStorage("refreshInterval") private var refreshInterval: Double = 60.0

    var body: some View {
        NavigationView {
            Form {
                // ── 그룹 이름 수정 섹션
                Section(header: Text("이름 수정")) {
                    NavigationLink(
                        destination: RenameGroupListView(vm: vm)
                    ) {
                        Text("그룹 이름 수정")
                    }
                }

                // ── 순서 변경 섹션
                Section(header: Text("순서 변경")) {
                    NavigationLink(destination: GroupOrderView(vm: vm)) {
                        Text("그룹 순서 변경")
                    }
                    NavigationLink(destination: ServerGroupsListView(vm: vm)) {
                        Text("서버 순서 변경")
                    }
                }

                // ── 새로고침 빈도 섹션
                Section(header: Text("새로고침 빈도 설정")) {
                    NavigationLink(destination: RefreshIntervalView()) {
                        HStack {
                            Text("새로고침 빈도 설정")
                            Spacer()
                            Text(RefreshIntervalView.displayLabel(for: refreshInterval))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // ── 앱 정보 섹션
                Section(header: Text("앱 정보")) {
                    if let info = Bundle.main.infoDictionary {
                        let version = info["CFBundleShortVersionString"] as? String ?? "-"
                        let build   = info["CFBundleVersion"] as? String ?? "-"
                        HStack {
                            Text("앱 버전")
                            Spacer()
                            Text(version)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("빌드 넘버")
                            Spacer()
                            Text(build)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("버전 정보를 불러올 수 없습니다")
                            .foregroundColor(.secondary)
                    }
                }

                // ── 한 줄 띄운 뒤 “gbnam” 이니셜 (섹션 구분으로 약간 여백 생김)
                Section {
                    HStack {
                        Spacer()
                        Text("gbnam")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .listRowBackground(Color(.systemGroupedBackground))
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
}
