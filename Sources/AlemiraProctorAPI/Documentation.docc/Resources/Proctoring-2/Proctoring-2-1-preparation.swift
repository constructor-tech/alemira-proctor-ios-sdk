import AlemiraProctor

extension SomeClass: SessionPreparationDelegate {
    func didRevertPhotoCheck() {
        ...
    }
    
    func didStartExamFail(leaveUrl: URL?) {
        if let leaveUrl {
            ...
        } else {
            ...
        }
    }
    
    func didGetExamURL() {
        ...
    }
}
