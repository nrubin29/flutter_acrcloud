import ACRCloudiOSSDK
import AVFoundation
import Flutter

/// Streams recognition events to Dart, buffering anything emitted before Dart listens.
private class EventStreamHandler: RecognitionEventsStreamHandler {
  private var pending: [AcrCloudEvent] = []
  private var sink: PigeonEventSink<AcrCloudEvent>?

  override func onListen(withArguments arguments: Any?, sink: PigeonEventSink<AcrCloudEvent>) {
    self.sink = sink
    for event in pending {
      sink.success(event)
    }
    pending.removeAll()
  }

  override func onCancel(withArguments arguments: Any?) {
    sink = nil
  }

  /// Emits `event` on the main thread. Platform channels are main-thread only.
  func emit(_ event: AcrCloudEvent) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      if let sink = self.sink {
        sink.success(event)
      } else if self.pending.count < 64 {
        // Keep the buffer bounded; a backlog this deep means nobody is listening.
        self.pending.append(event)
      }
    }
  }
}

public class FlutterAcrcloudPlugin: NSObject, FlutterPlugin, AcrCloudHostApi {
  private let events = EventStreamHandler()

  private var client: ACRCloudRecognition?
  private var sessionId: Int64 = 0
  private var activeSessionId: Int64?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FlutterAcrcloudPlugin()
    AcrCloudHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    RecognitionEventsStreamHandler.register(
      with: registrar.messenger(),
      streamHandler: instance.events
    )
    // Keeps `instance` alive for the engine's lifetime. Pigeon's setUp does not
    // retain the API object the way addMethodCallDelegate did.
    registrar.publish(instance)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    releaseClient()
  }

  // MARK: - AcrCloudHostApi

  func requestMicrophonePermission(
    completion: @escaping (Result<AcrCloudPermissionStatus, Error>) -> Void
  ) {
    if #available(iOS 17.0, *) {
      switch AVAudioApplication.shared.recordPermission {
      case .granted:
        completion(.success(.granted))
      case .denied:
        completion(.success(.permanentlyDenied))
      default:
        AVAudioApplication.requestRecordPermission { granted in
          completion(.success(granted ? .granted : .denied))
        }
      }
    } else {
      let session = AVAudioSession.sharedInstance()
      switch session.recordPermission {
      case .granted:
        completion(.success(.granted))
      case .denied:
        completion(.success(.permanentlyDenied))
      default:
        session.requestRecordPermission { granted in
          completion(.success(granted ? .granted : .denied))
        }
      }
    }
  }

  func configure(
    config: AcrCloudConfigMessage,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    releaseClient()

    let acrConfig = ACRCloudConfig()
    acrConfig.accessKey = config.accessKey
    acrConfig.accessSecret = config.accessSecret
    acrConfig.host = config.host
    acrConfig.recMode = rec_mode_remote
    acrConfig.recDataType = rec_data_audio
    acrConfig.protocol = config.useHttps ? "https" : "http"
    acrConfig.requestTimeout = max(1, Int(config.requestTimeoutMs / 1000))

    acrConfig.resultBlock = { [weak self] result, resultType in
      self?.handleResult(result, resultType)
    }
    acrConfig.volumeBlock = { [weak self] volume in
      self?.handleVolume(volume)
    }

    guard let recognition = ACRCloudRecognition(config: acrConfig) else {
      completion(
        .failure(
          AcrCloudPigeonError(
            code: "INIT_FAILED",
            message: "The ACRCloud SDK failed to initialize. Check your credentials and host.",
            details: nil
          )
        )
      )
      return
    }

    client = recognition
    completion(.success(()))
  }

  func startRecognition(completion: @escaping (Result<Int64, Error>) -> Void) {
    guard let client else {
      completion(.failure(notConfigured()))
      return
    }

    guard activeSessionId == nil else {
      completion(
        .failure(
          AcrCloudPigeonError(
            code: "ALREADY_LISTENING",
            message: "A session is already running.",
            details: nil
          )
        )
      )
      return
    }

    sessionId += 1
    activeSessionId = sessionId
    client.startRecordRec()
    completion(.success(sessionId))
  }

  func cancelRecognition(
    sessionId: Int64,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard activeSessionId == sessionId else {
      completion(.success(()))
      return
    }

    activeSessionId = nil
    // `stopRecordRec` aborts without recognizing, matching Android's `cancel()`.
    client?.stopRecordRec()
    completion(.success(()))
  }

  func stopAndRecognize(
    sessionId: Int64,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard activeSessionId == sessionId else {
      completion(.success(()))
      return
    }

    client?.stopRecordAndRec()
    completion(.success(()))
  }

  func release(completion: @escaping (Result<Void, Error>) -> Void) {
    releaseClient()
    completion(.success(()))
  }

  // MARK: - SDK callbacks

  private func handleResult(_ result: String?, _ resultType: ACRCloudResultType) {
    guard let id = activeSessionId else { return }
    activeSessionId = nil

    guard let result, resultType != result_type_error else {
      events.emit(
        AcrCloudErrorEvent(
          sessionId: id,
          code: "NO_RESULT",
          message: "The SDK returned an empty or failed result."
        )
      )
      return
    }

    events.emit(AcrCloudResultEvent(sessionId: id, resultJson: result))
  }

  private func handleVolume(_ volume: Float) {
    guard let id = activeSessionId else { return }
    events.emit(AcrCloudVolumeEvent(sessionId: id, volume: Double(volume)))
  }

  // MARK: - Helpers

  private func notConfigured() -> AcrCloudPigeonError {
    AcrCloudPigeonError(
      code: "NOT_CONFIGURED",
      message: "The ACRCloud client is not configured. Call configure() first.",
      details: nil
    )
  }

  private func releaseClient() {
    if activeSessionId != nil {
      client?.stopRecordRec()
      activeSessionId = nil
    }
    client = nil
  }
}
