# AlemiraProctor iOS SDK v2.1.0

The library provides proctoring functions

## Overview

The library records video from the front camera and screen, manages the single application mode, and also performs all the necessary work with the session: 
* opening, closing;
* sending logs, pings, messages, videos;
* getting a list of sessions;
* etc.

You can also get library logs.

## Implementation Proctoring SDK For iOS

The tutorial will help you understand which methods to call and in what order.

Estimated Time - 5 min

## Section 1
#### Main methods
This section contains methods that you must call in order to correctly start the session.

#### Step 1
First you need to set session host, session id and session token from the provided URL
```swift
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
```
Then initialize the session like following. Returns true if the session has already started and can be continued. False if the session has not been started or received chunks.

```swift
import AlemiraProctoring

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
```

If the error is due to the fact that the exam does not exist, cannot be started yet, or the link is not valid, it will return AlemiraError.InitSessionErrorReason. If the error was due to something else, then another appropriate AlemiraError type will be returned.

#### Step 2
After that user should accept a license agreement.
```swift
import AlemiraProctoring

AlemiraLib.instance.session?.getAgreement()

AlemiraLib.instance.session?.sendAgreement { [weak self] result in
    switch result {
    case .success(_): ...
    case .failure(_): ...
    }
}
```
You can get an agreement using a getAgreement() method

#### Step 3
To be sure that the recording will start, you need to check that you have access to the camera and microphone.
```swift
import AlemiraProctoring

AlemiraLib.instance.checkPermissions { [weak self] result in
    if result.micEnabled && result.cameraEnabled {
        ...
    } else {
        ...
    }
}
```

#### Step 4
Before taking a photo of a user and/or his documents, you must start a session on the server. You also need to request the required types of photos.
```swift
import AlemiraProctoring

AlemiraLib.instance.session?.startSession(completion: { [weak self] result in
    switch result {
    case .failure(_): ...
    case .success(_): ...
    }
})

AlemiraLib.instance.session?.getPhotoTypes(completion: { [weak self] result in
    switch result {
    case .success(let types): ...
    default: ...
    }
})
```

#### Step 5
When sending a photo, it is necessary to pass photo date to the method, as well as the type of photo from PhotoType enumeration .
```swift
import AlemiraProctoring

guard let image = info[.originalImage] as? UIImage,
      let imageData = image.jpegData(compressionQuality: 0.7)
else {
    return
}
let type: PhotoType
...
AlemiraLib.instance.session?.uploadPhoto(imageData: imageData, type: type) { [weak self] result in
    switch result {
    case .success(_): ...
    default: break
    }
}
```

#### Step 6
After uploading the photos, the library will be ready to start proctoring. To do this, you need to call the start method. If the user accepts the switch to single app mode and starts screen recording, a link to the exam will be returned in response.
```swift
import AlemiraProctoring

AlemiraLib.instance.session?.startProctoring(delegate: self) { [weak self] result in
    switch result {
    case .success(let url):
        self?.webView.load(URLRequest(url: url))
    case .failure(_): ...
    }
}
```
In some cases, it can be missing, which will lead to an error. If this happens - call the method again if no error method was called while preparing the session

#### Step 7
When the user wants to complete the exam, it is necessary to send information about this to the library
```swift
import AlemiraProctoring

AlemiraLib.instance.session?.stopSession()
```

#### Step 8
You can disable the single app mode if the user has lost the Internet connection.
```swift
import AlemiraProctoring

AlemiraLib.instance.session?.changeSingleAppModeState(for: true, completion: { result in
    switch result {
    case .success(let success):
        ...
    case .failure(let failure):
        ...
    }
})
```
When you turn it on and off, you will get a delegate method about interrupting and resuming

#### Step 9
During the proctoring session it is also available to show the camera preview to the user. To do this, you need to call and subscribe to the method getVideoBuffer()
```swift
import AlemiraProctoring

AlemiraLib.instance.session?.getVideoBuffer()
```
This will allow you to implement additional logic to the video output.

In some cases it may be required to detect face amount in the provided video output, to perform this logic you need to call ```getDetectedFacesCount()``` method. 
```swift
import Combine
import AlemiraProctoring

guard let buffer = AlemiraLib.instance.session?.getVideoBuffer(),
      let currentOrientation = .portrait
else {
    return
}

AlemiraLib.instance.getDetectedFacesCount(in: buffer, orientation: currentOrientation)
    .sink(
        receiveCompletion: { _ in },
        receiveValue: { [weak self] facesCount in
            ...
    })
    .store(in: &cancellableBag)
```

### Section 2
### Delegates
When preparing a session for proctoring and during it, situations may arise that it is desirable to handle.

#### Step 1
During the preparation of the session, it is necessary to conforms the protocol ‘SessionPreparationDelegate’.
```swift
import AlemiraProctoring

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
```
Then, if the photo is rejected by a proctor, there was an error getting the link to the exam or everything is ok and exam link was received, the library will call the appropriate method.

#### Step 2
When a session is proctored, the stop method is called when it ends, and then when all the videos are loaded, the finish method is called. At the same time, during the session, methods of interrupting and resuming the session can be called if the video cannot be loaded.
```swift
import AlemiraProctoring

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
```
To restrict the user while the session is stopped, you can, for example, apply a blur

#### Step 3
It is also possible to receive errors that occur during library operation. To do this, you need to conform to the ‘LoggerDelegate’
```swift
import AlemiraProctoring

AlemiraLib.instance.setLoggingEnabled(true)
AlemiraLib.instance.setErrorHandler(delegate: self)

extension ErrorHandlerClass: LoggerDelegate {
    func receivedError(_ error: AlemiraError) {
        ...
    }
}
```
You can also turn off receiving errors at any time. Enabled by default.
