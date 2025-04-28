// Utilities/ErrorTranslator.swift

import Foundation

func translateError(_ error: String) -> String {
  if error.contains("kCFErrorDomainCFNetwork error 2") { return "호스트를 찾을 수 없습니다" }
  switch error {
    case "Timeout": return "시간 초과"
    case "Connection refused": return "연결이 거부되었습니다"
    case "Network is unreachable": return "네트워크에 연결할 수 없습니다"
    case "Host not found", "nodename nor servname provided, or not known": return "호스트를 찾을 수 없습니다"
    default: return error
  }
}
