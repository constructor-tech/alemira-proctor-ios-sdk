import AlemiraProctor

AlemiraLib.instance.session?.startProctoring(delegate: self) { [weak self] result in
    switch result {
    case .success(let url):
        self?.webView.load(URLRequest(url: url))
    case .failure(_): ...
    }
}
