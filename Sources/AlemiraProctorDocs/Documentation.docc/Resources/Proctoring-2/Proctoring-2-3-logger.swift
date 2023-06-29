import AlemiraProctor

AlemiraLib.instance.setLoggingEnabled(true)
AlemiraLib.instance.setErrorHandler(delegate: self)

extension ErrorHandlerClass: LoggerDelegate {
    func receivedError(_ error: AlemiraError) {
        ...
    }
}
