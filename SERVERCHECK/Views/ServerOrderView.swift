// Views/ServerOrderView.swift

import SwiftUI

struct ServerOrderView: View {
    @ObservedObject var vm: ServerListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var editMode: EditMode = .active
    @State private var currentGroupIndex: Int?

    var body: some View {
        NavigationView {
            List {
                if let gi = currentGroupIndex, gi < vm.groups.count {
                    ForEach(vm.groups[gi].servers) { server in
                        Text(server.name)
                    }
                    .onMove { indices, newOffset in
                        vm.moveServer(in: vm.groups[gi], fromOffsets: indices, toOffset: newOffset)
                    }
                } else {
                    ForEach(vm.groups.first?.servers ?? []) { server in
                        Text(server.name)
                    }
                    .onMove { indices, newOffset in
                        if let first = vm.groups.first {
                            vm.moveServer(in: first, fromOffsets: indices, toOffset: newOffset)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .listStyle(InsetGroupedListStyle())
            .environment(\.editMode, $editMode)
            .navigationTitle("서버 순서 변경")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
