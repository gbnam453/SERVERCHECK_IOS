// Views/RenameGroupView.swift

import SwiftUI

/// 그룹 이름을 수정하는 별도 화면
struct RenameGroupView: View {
    @ObservedObject var vm: ServerListViewModel
    let groupIndex: Int
    
    @State private var newName: String = ""
    @Environment(\.dismiss) private var dismiss

    init(vm: ServerListViewModel, groupIndex: Int) {
        self.vm = vm
        self.groupIndex = groupIndex
        // 초기값으로 현재 그룹 이름 채워두기
        _newName = State(initialValue: vm.groups[groupIndex].name)
    }
    
    var body: some View {
        Form {
            Section(header: Text("새 그룹 이름")) {
                TextField("그룹 이름", text: $newName)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .navigationTitle("그룹 이름 수정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") {
                    let trimmed = newName.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    vm.renameGroup(at: groupIndex, newName: trimmed)
                    dismiss()
                }
            }
        }
    }
}
