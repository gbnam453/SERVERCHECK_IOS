// Views/RefreshIntervalView.swift

import SwiftUI

struct RefreshIntervalView: View {
    // AppStorage에 저장된 간격 (초 단위, 0이면 사용 안 함)
    @AppStorage("refreshInterval") private var interval: Double = 60.0

    // 선택 가능한 간격 목록 (실시간 0.1초 → 300초)
    static let options: [(label: String, value: Double)] = [
        ("사용 안 함", 0.0),
        ("실시간(BETA)", 0.5),
        ("3초", 3.0),
        ("5초", 5.0),
        ("10초", 10.0),
        ("15초", 15.0),
        ("30초", 30.0),
        ("1분", 60.0),
        ("3분", 180.0),
        ("5분", 300.0)
    ]

    var body: some View {
        Form {
            Section {
                Picker(selection: $interval, label: EmptyView()) {
                    ForEach(Self.options, id: \.value) { item in
                        Text(item.label).tag(item.value)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
        .navigationTitle("새로고침 빈도")
        .navigationBarTitleDisplayMode(.inline)
    }

    // 현재 저장된 간격에 해당하는 라벨 반환
    static func displayLabel(for value: Double) -> String {
        return options.first(where: { $0.value == value })?.label ?? "\(Int(value))초"
    }
}
