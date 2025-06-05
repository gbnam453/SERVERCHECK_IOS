// Views/RenameGroupListView.swift

import SwiftUI

/// 그룹 목록을 보여주고, 탭하면 RenameGroupView로 이동합니다.
struct RenameGroupListView: View {
    @ObservedObject var vm: ServerListViewModel

    var body: some View {
        List {
            ForEach(vm.groups.indices, id: \.self) { idx in
                NavigationLink(destination: RenameGroupView(vm: vm, groupIndex: idx)) {
                    Text(vm.groups[idx].name)
                }
            }
        }
        .navigationTitle("그룹 선택")
        .navigationBarTitleDisplayMode(.inline)
    }
}
