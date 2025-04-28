// Utilities/NetworkChecker.swift

import Foundation
import Network

struct NetworkChecker {
    private static let tcpTimeout: TimeInterval = 3.0

    /// 서버 타입에 따라 Ping/TCP/HTTP 헬스체크
    /// completion: (isUp, rtt(ms), errorMessage, httpStatusCode)
    static func check(
        server: Server,
        completion: @escaping (Bool, Double?, String?, Int?) -> Void
    ) {
        switch server.type {
        case .ping:
            let helper = PingHelper()
            helper.ping(host: server.host, timeout: tcpTimeout) { ok, time, err in
                completion(ok, time, err, nil)
            }

        case .tcp:
            tcp(host: server.host, port: server.port ?? 80) { ok, time, err in
                completion(ok, time, err, nil)
            }

        case .http:
            httpCheck(host: server.host, port: server.port ?? 80, completion: completion)
        }
    }

    // MARK: - TCP 체크 (SYN)
    private static func tcp(
        host: String,
        port: UInt16,
        completion: @escaping (Bool, Double?, String?) -> Void
    ) {
        let nwPort = NWEndpoint.Port(rawValue: port) ?? .http
        let conn = NWConnection(host: .init(host), port: nwPort, using: .tcp)
        var didFinish = false
        let start = Date()

        conn.stateUpdateHandler = { state in
            guard !didFinish else { return }
            switch state {
            case .ready:
                didFinish = true
                let elapsed = Date().timeIntervalSince(start) * 1000
                completion(true, elapsed, nil)
                conn.cancel()

            case .failed(let error), .waiting(let error):
                didFinish = true
                completion(false, nil, translateError(error.localizedDescription))
                conn.cancel()

            default:
                break
            }
        }
        conn.start(queue: .global())

        DispatchQueue.global().asyncAfter(deadline: .now() + tcpTimeout) {
            guard !didFinish else { return }
            didFinish = true
            completion(false, nil, translateError("Timeout"))
            conn.cancel()
        }
    }

    // MARK: - HTTP 체크 (HEAD)
    private static func httpCheck(
        host: String,
        port: UInt16,
        completion: @escaping (Bool, Double?, String?, Int?) -> Void
    ) {
        // 전체 URL을 입력한 경우 그대로 사용, host에 path 포함 시 처리
        let urlString: String
        if host.lowercased().hasPrefix("http://") || host.lowercased().hasPrefix("https://") {
            urlString = host
        } else if let slashIdx = host.firstIndex(of: "/") {
            let hostname = String(host[..<slashIdx])
            let path     = String(host[slashIdx...])
            urlString = "http://\(hostname):\(port)\(path)"
        } else {
            urlString = "http://\(host):\(port)/"
        }

        guard let url = URL(string: urlString) else {
            completion(false, nil, translateError("Invalid URL"), nil)
            return
        }

        let start = Date()
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        URLSession.shared.dataTask(with: request) { _, response, error in
            let elapsed = Date().timeIntervalSince(start) * 1000
            if let httpResponse = response as? HTTPURLResponse {
                let ok = (200..<300).contains(httpResponse.statusCode)
                completion(ok, elapsed, nil, httpResponse.statusCode)
            } else if let error = error {
                completion(false, nil, translateError(error.localizedDescription), nil)
            } else {
                completion(false, nil, translateError("No response"), nil)
            }
        }
        .resume()
    }
}
