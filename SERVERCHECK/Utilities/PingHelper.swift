// Utilities/PingHelper.swift

import Foundation

/// SimplePing을 활용한 ICMP 핑 헬퍼
class PingHelper: NSObject {
    private var pinger: SimplePing?
    private var startDate: Date?
    private var completion: ((Bool, Double?, String?) -> Void)?
    private var selfRetain: PingHelper?  // 인스턴스 유지용

    /// host에 ICMP 핑을 보내고, timeout(초) 이후 실패로 간주
    func ping(host: String, timeout: TimeInterval = 3.0, completion: @escaping (Bool, Double?, String?) -> Void) {
        self.selfRetain = self
        self.completion = completion

        let p = SimplePing(hostName: host)
        self.pinger = p
        p.delegate = self
        p.start()

        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) { [weak self] in
            guard let self = self else { return }
            self.pinger?.stop()
            self.finish(success: false, time: nil, error: translateError("Timeout"))
        }
    }

    private func finish(success: Bool, time: Double?, error: String?) {
        defer { selfRetain = nil }
        let cb = completion
        completion = nil
        pinger = nil
        cb?(success, time, error)
    }
}

extension PingHelper: SimplePingDelegate {
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        startDate = Date()
        pinger.send(with: nil)
    }

    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        guard let start = startDate else { return }
        let rtt = Date().timeIntervalSince(start) * 1000
        pinger.stop()
        finish(success: true, time: rtt, error: nil)
    }

    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        pinger.stop()
        finish(success: false, time: nil, error: translateError(error.localizedDescription))
    }

    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        pinger.stop()
        finish(success: false, time: nil, error: translateError(error.localizedDescription))
    }
}
