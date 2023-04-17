import Foundation
import AlemiraProctor

protocol AlemiraLib {
    static var instance: Alemira { get }
}

/// The protocol provides methods for preparing work with a session: error logging, session initialization and access to it
public protocol Alemira {
    /// The current session created in the function ``initSession(with:completion:)`` using a link
    var session: AlemiraSession? { get }
    /// Parse the link and create a session object
    ///
    /// - Parameters:
    ///   - url: The link looks like `Alemira://{host}/?session={sessionId}&token={sessionToken}`
    ///   - completion: Success: return true if exam was started and exam url was received and false if url is missing.
    ///   Failure: The error can be related to both the link itself and the session parameters.
    ///   A special enum ``InitSessionErrorReason`` is used to describe initialization errors.
    ///   If it returns an error, it sets the session variable to nil
    func initSession(with url: URL, completion: @escaping (Result<Bool, AlemiraError>) -> Void)
    /// Set a library logger delegate
    /// - Parameters:
    ///   - delegate: AnyObject that conforms to ``LoggerDelegate`` protocol.
    ///
    /// When you set a delegate, if an error occurs, it will be called provided that logging is enabled
    func setErrorHandler(delegate: LoggerDelegate)
    /// You can enable and disable logging. Default enabled
    func setLoggingEnabled(_ status: Bool)
    /// Checks for access to the camera and microphone
    /// - Parameters:
    ///   - completion: Accepts a closure, which is passed a structure containing information about each permission
    func checkPermissions(completion: @escaping (Permissions) -> Void)
    /// The method is used to diversify the behavior of transitions if the permission status is already determined
    ///
    /// - Returns: Means whether permissions were determined
    func wasPermissionsDetermined() -> Bool
}
