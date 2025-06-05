// Views/ServerGroupsListView.swift

import SwiftUI

struct ServerGroupsListView: View {
    @ObservedObject var vm: ServerListViewModel

    var body: some View {
        List {
            if vm.groups.isEmpty {
                Text("그룹이 없습니다")
                    .foregroundColor(.secondary)
            } else {
                ForEach(vm.groups.indices, id: \.self) { idx in
                    NavigationLink(destination: ServerOrderViewForGroup(vm: vm, groupIndex: idx)) {
                        Text(vm.groups[idx].name)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("서버 순서 변경")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 선택된 그룹 내 서버를 드래그하여 순서를 변경할 수 있는 화면
struct ServerOrderViewForGroup: View {
    @ObservedObject var vm: ServerListViewModel
    @Environment(\.dismiss) private var dismiss

    let groupIndex: Int
    @State private var editMode: EditMode = .active

    var body: some View {
        List {
            ForEach(vm.groups[groupIndex].servers) { server in
                Text(server.name)
            }
            .onMove { indices, newOffset in
                vm.moveServer(in: vm.groups[groupIndex], fromOffsets: indices, toOffset: newOffset)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .environment(\.editMode, $editMode)
        .navigationTitle(vm.groups[groupIndex].name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("완료") {
                    dismiss()
                }
            }
        }
    }
}
