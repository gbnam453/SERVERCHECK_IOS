// Views/ServerCardView.swift

import SwiftUI

/// 서버 상태를 카드 형식으로 표시하는 뷰
struct ServerCardView: View {
    let server: Server

    /// host:port 문자열
    private var addressText: String {
        if let p = server.port {
            return "\(server.host):\(p)"
        } else {
            return server.host
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 1. 이름과 주소
            HStack {
                Text(server.name)
                    .font(.headline)
                Spacer()
                Text(addressText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // 2. 진행 바 (baseline 및 색상 임계값 적용)
            GeometryReader { geo in
                let rt = server.responseTime ?? 0
                // 체크 유형별 기준 설정
                let baseline: Double = server.type == .http ? 1000.0 : 150.0
                let greenThreshold: Double = server.type == .http ? 300.0 : 50.0
                let yellowThreshold: Double = server.type == .http ? 600.0 : 100.0
                let fraction = server.status == .down ? 1.0 : min(rt / baseline, 1.0)

                // 색상 결정: 오류(빨강), 녹색, 노란색, 주황색
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
                    Capsule()
                        .fill(fillColor)
                        .frame(width: geo.size.width * CGFloat(fraction), height: 6)
                }
            }
            .frame(height: 6)

            // 3. 응답 시간 또는 에러 메시지와 체크 유형
            HStack {
                Group {
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
                    server.status == .down || server.responseError != nil
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
