import AlemiraProctor

AlemiraLib.instance.session?.getAgreement()

AlemiraLib.instance.session?.sendAgreement { [weak self] result in
    switch result {
    case .success(_): ...
    case .failure(_): ...
    }
}
