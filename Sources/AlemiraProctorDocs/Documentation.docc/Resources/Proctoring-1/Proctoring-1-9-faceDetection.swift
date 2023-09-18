import Combine
import AlemiraProctor

let currentOrientation = UIApplication.shared.interfaceOrientation()
var cancellableBag = Set<AnyCancellable>()

if let buffer = AlemiraLib.instance.getVideoBuffer().value {
    AlemiraLib.instance.getDetectedFacesCount(in: buffer, orientation: currentOrientation)
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { facesCount in
                ...
            })
        .store(in: &cancellableBag)
}

// Mark: Private

extension UIApplication {
    private func interfaceOrientation() -> UIInterfaceOrientation {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first { $0.isKeyWindow }?
            .windowScene?
            .interfaceOrientation ?? .unknown
    }
}
