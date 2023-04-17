import AlemiraProctor

extension ExamClass: SessionStatusDelegate {
    func didStopSession() {
        ...
        blurView.isHidden = false
    }
    
    func didFinishSession(leaveUrl: URL?) {
        if let url = leaveUrl {
            webView.load(URLRequest(url: url))
        } else {
            ...
        }
    }
    
    func didInterruptSession(reason: InterruptReason) {
        blurView.isHidden = false
    }
    
    func didResumeSession(reason: InterruptReason) {
        blurView.isHidden = true
    }
}
