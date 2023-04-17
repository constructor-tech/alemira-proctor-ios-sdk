import Foundation
import AlemiraProctor

/// The protocol gives all the necessary methods that are associated with changing the state of the session
public protocol SessionStatusDelegate: AnyObject {
    /// If it is impossible to load any video after 6 attempts, this method is called.
    ///
    /// - Parameters:
    ///   - reason: case from ``InterruptReason`` enum
    ///
    /// It is assumed that there are problems with the Internet, so it is worth, for example, turning on the screen blur.
    /// Meanwhile, proctoring continues.
    func didInterruptSession(reason: InterruptReason)
    /// If any video has loaded after the session was interrupted, then this method is called.
    ///
    /// - Parameters:
    ///   - reason: case from ``InterruptReason`` enum
    ///
    /// It is worth removing the restrictions on passing the exam, imposed by the interruption method
    func didResumeSession(reason: InterruptReason)
    /// Called when proctoring stops
    ///
    /// It, in turn, can be called after the session is stopped by the user, and in case of problems with pings: the server closed the session or pings stopped reaching.
    func didStopSession()
    /// Called when all videos have loaded after proctoring has stopped or 3 minutes have passed
    /// - Parameters:
    ///   - leaveUrl: If a link is passed, then you need to redirect a user to it
    func didFinishSession(leaveUrl: URL?)
}

/// Delegate protocol used to receive errors when preparing a session to start proctoring
public protocol SessionPreparationDelegate: AnyObject {
    /// Method is called if a system message has arrived that the photo was rejected.
    ///
    /// After receiving this event, it will be necessary to transfer the user to the stage of photographing again
    func didRevertPhotoCheck()
    /// Method is called when unexpected errors occur while preparing the session for proctoring and getting the exam link
    ///
    /// - Parameters:
    ///   - leaveUrl: If a link is passed, then you need to redirect a user to it
    /// It is necessary to notify a user about it.
    func didStartExamFail(leaveUrl: URL?)
    /// Method is called when we get exam url from messages.
    ///
    /// It's recommended to wait for this method to be called before allowing the user to start the exam
    func didGetExamURL()
}

/// The protocol gives all the necessary methods that are associated with the session
public protocol AlemiraSession {
    /// Current session id
    var sessionId: String { get }
    /// Open a session on a server to work with it
    /// - Parameters:
    ///   - completion: A closure that passes success with a session object from a server or failure with an error
    ///   Session start should be called before uploading photos to a server. Also this method starts sending messages and pings to the server
    func startSession(completion: @escaping (Result<SessionDTO, AlemiraError>) -> Void)
    /// Locks a user on the application and starts recording video.
    /// - Parameters:
    ///   - delegate: A session delegate that will receive events about session status changes
    ///   - completion: If successful, a link to the site where an exam is held is passed to the closure
    ///  If the user did not allow the activation of single app mode or screen recording, as well as in the missing of a link to the exam and inappropriate session status: for example, photos were not uploaded, the session was not started, then an error will be returned. In other cases, it will return a link to the exam
    func startProctoring(delegate sessionDelegate: SessionStatusDelegate, completion: @escaping (Result<URL, AlemiraError>) -> Void)
    /// Sends a message to the server about closing the session on the initiative of the user
    /// - Parameters:
    ///   - completion: Returns a server message if successful
    /// Calls the session delegate's method to stop the session. Completes proctoring and starts the process of waiting for the video to be uploaded. Waiting time is 3 minutes.
    /// After the time has elapsed or all videos have been downloaded, a message is sent to the server stating that there will be no new videos. The delegate receives the completion event
    func stopSession(completion: @escaping (Result<MessageDTO, AlemiraError>) -> Void)
    /// Returns the type of photos that should be uploaded
    func getPhotoTypes(completion: @escaping (Result<RequiredPhotoType, AlemiraError>) -> Void)
    /// Makes the necessary transformations of photo data and sends it to a server
    /// - Parameters:
    ///   - imageData: Photo taken data
    ///   - type: Photo upload type: passport or face
    ///   - completion: Returns a system message if successful
    ///   Photo data is converted to a base64 string. If all the required photos have already been uploaded, no new ones will be sent.
    func uploadPhoto(imageData: Data, type: PhotoType, completion: @escaping (Result<MessageDTO, AlemiraError>) -> Void)
    /// Makes a request to the server to get user information
    /// - Parameters:
    ///   - completion:Returns full information about the user
    func getUser(completion: @escaping (Result<UserDTO, AlemiraError>) -> Void)
    /// Sends a message to the server that the user has accepted the user agreement before starting the session
    /// - Parameters:
    ///   - completion: Returns a status of a request
    /// Without accepting the agreement, it will not be possible to start a session, send a photo, etc.
    func sendAgreement(completion: @escaping (Result<SendAgreementDTO, AlemiraError>) -> Void)
    /// Allows you to get all sessions available to a user
    /// - Parameters:
    ///   - completion: Returns an array with information about sessions
    ///   This method can be used to allow a user to take other exams available to him.
    func getSessions(completion: @escaping (Result<[SessionDTO], AlemiraError>) -> Void)
    /// Method allows you to get an agreement that needs to be displayed to the user
    ///
    /// - Returns: HTML-string, that you can load with WebKit
    func getAgreement() -> String
    
    /// Allows you to change single app mode state
    ///
    /// - Parameters:
    ///   - enabled: Necessary state
    ///   - completion: If the state was changed and did not match the current one, it will return `.success(Void)`
    ///
    ///   This method should be used to allow the user to change the Internet connection. In this case, the exam must be interrupted
    func changeSingleAppModeState(for enabled: Bool, completion: @escaping (Result<Void, AlemiraError>) -> Void)
}
