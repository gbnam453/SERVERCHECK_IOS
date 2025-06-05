// Views/ServerCardView.swift

import SwiftUI

struct ServerCardView: View {
    let server: Server

    private var addressText: String {
        if let p = server.port {
            return "\(server.host):\(p)"
        } else {
            return server.host
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 1. 이름 + 주소
            HStack {
                Text(server.name)
                    .font(.headline)
                Spacer()
                Text(addressText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // 2. 상태 표시 캡슐 바 (애니메이션 추가)
            GeometryReader { geo in
                let rt = server.responseTime ?? 0
                // HTTP는 1000ms 기준, 그 외는 150ms 기준
                let baseline: Double = (server.type == .http) ? 1000.0 : 150.0
                // HTTP: 녹색 ≤300, 노랑 ≤600, 주황 ≤1000. TCP/PING: 녹색 ≤50, 노랑 ≤100, 주황 ≤150
                let greenThreshold: Double  = (server.type == .http) ? 300.0 : 50.0
                let yellowThreshold: Double = (server.type == .http) ? 600.0 : 100.0
                let fraction = (server.status == .down)
                    ? 1.0
                    : min(rt / baseline, 1.0)

                let fillColor: Color = {
                    if server.status == .down {
                        return .red
                    } else if rt <= greenThreshold {
                        return .green
                    } else if rt <= yellowThreshold {
                        return .yellow
                    } else {
                        return .orange
                    }
                }()

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 6)

                    // 애니메이션이 걸린 부분: fraction 값이 변경될 때 부드럽게 늘어납니다.
                    Capsule()
                        .fill(fillColor)
                        .frame(
                            width: geo.size.width * CGFloat(fraction),
                            height: 6
                        )
                        .animation(.easeInOut(duration: 0.3), value: fraction)
                }
            }
            .frame(height: 6)

            // 3. 응답 시간/에러 메시지 + 체크 유형
            HStack {
                SwiftUI.Group {
                    if server.status == .down, let code = server.responseStatusCode {
                        Text("HTTP status: \(code)")
                    } else if let err = server.responseError {
                        Text(err)
                    } else if let rt = server.responseTime {
                        Text("\(Int(rt)) ms")
                    } else {
                        Text("")
                    }
                }
                .font(.caption)
                .foregroundColor(
                    (server.status == .down || server.responseError != nil)
                        ? .red : .secondary
                )

                Spacer()

                Text(server.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(minHeight: 18)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
