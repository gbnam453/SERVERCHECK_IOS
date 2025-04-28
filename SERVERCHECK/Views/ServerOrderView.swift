// Views/ServerOrderView.swift

import SwiftUI

/// 서버 정렬 순서 변경 화면
struct ServerOrderView: View {
    @ObservedObject var vm: ServerListViewModel
    @Environment(\.dismiss) private var dismiss

    // 편집 모드 항상 활성화
    @State private var editMode: EditMode = .active

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.servers) { server in
                    Text(server.name)
                }
                .onMove { indices, newOffset in
                    vm.servers.move(fromOffsets: indices, toOffset: newOffset)
                    vm.saveServers()
                }
            }
            // 리스트 자체의 흰 배경 제거
            .scrollContentBackground(.hidden)
            // 그룹형 배경색 깔기
            .background(Color(.systemGroupedBackground))
            .listStyle(InsetGroupedListStyle())
            .environment(\.editMode, $editMode)
            .navigationTitle("순서 변경")
            .toolbar {
                // 우측 상단 완료 버튼
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        // NavigationView 전체 배경도 맞춰주기
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
