// Views/GroupOrderView.swift

import SwiftUI

struct GroupOrderView: View {
    @ObservedObject var vm: ServerListViewModel
    @Environment(\.dismiss) private var dismiss

    // 항상 편집 모드 활성화
    @State private var editMode: EditMode = .active

    var body: some View {
        // NavigationView를 제거하고, List만 남깁니다.
        List {
            ForEach(vm.groups) { group in
                Text(group.name)
            }
            .onMove { indices, newOffset in
                vm.moveGroup(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .environment(\.editMode, $editMode)
        .navigationTitle("그룹 순서 변경")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // SettingsView에서 푸시된 상태이므로, 뒤로가기 버튼(자동 추가) 및 완료 버튼만 남깁니다.
            ToolbarItem(placement: .confirmationAction) {
                Button("완료") {
                    dismiss()
                }
            }
        }
    }
}
