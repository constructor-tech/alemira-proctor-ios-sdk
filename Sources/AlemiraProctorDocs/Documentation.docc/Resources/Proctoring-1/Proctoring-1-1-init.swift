import AlemiraProctor


let link: URL = URL(string: "alemira://...&token=...&sessionId=...")
var url: String? = link.host
var sessionId: String?
var token: String?

let components = link.absoluteString.components(separatedBy: "&")

if let range = components.first?.range(of: "sessionId=") {
    sessionId = String(components.first?[sessionRange.upperBound...] ?? "")
}

if let range = components.last?.range(of: "token=") {
    token = String(components.last?[range.upperBound...] ?? "")
}

AlemiraLib.instance.setBackendUrl(url)
AlemiraLib.instance.setExamSessionId(sessionId)
AlemiraLib.instance.setApiToken(token)

AlemiraLib.instance.initSession { result in
    switch result {
    case .success(let success):
        if success {
            ...
        } else {
            ...
        }
    case .failure(let failure):
        if case AlemiraErrorType.initSessionError = failure {
            switch failure {
            case ...
            }
        } else {
            ...
        }
    }
    
}
