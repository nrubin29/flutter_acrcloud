package com.noahzrubin.flutter_acrcloud

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import com.acrcloud.rec.ACRCloudClient
import com.acrcloud.rec.ACRCloudConfig
import com.acrcloud.rec.ACRCloudResult
import com.acrcloud.rec.IACRCloudListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry

private const val PERMISSION_REQUEST_CODE = 29

/** Streams recognition events to Dart, buffering anything emitted before Dart listens. */
private class EventStreamHandler : RecognitionEventsStreamHandler() {
  private val pending = ArrayDeque<AcrCloudEvent>()
  private var sink: PigeonEventSink<AcrCloudEvent>? = null

  override fun onListen(p0: Any?, sink: PigeonEventSink<AcrCloudEvent>) {
    this.sink = sink
    while (pending.isNotEmpty()) {
      sink.success(pending.removeFirst())
    }
  }

  override fun onCancel(p0: Any?) {
    sink = null
  }

  /** Emits [event] on the main thread. Platform channels are main-thread only. */
  fun emit(event: AcrCloudEvent) {
    Handler(Looper.getMainLooper()).post {
      val sink = this.sink
      if (sink == null) {
        // Keep the buffer bounded; a backlog this deep means nobody is listening.
        if (pending.size < 64) pending.addLast(event)
      } else {
        sink.success(event)
      }
    }
  }
}

/** FlutterAcrcloudPlugin */
class FlutterAcrcloudPlugin :
  FlutterPlugin,
  ActivityAware,
  AcrCloudHostApi,
  PluginRegistry.RequestPermissionsResultListener {

  private lateinit var context: Context
  private val events = EventStreamHandler()

  private var activityBinding: ActivityPluginBinding? = null
  private val activity: Activity?
    get() = activityBinding?.activity

  private var client: ACRCloudClient? = null
  private var sessionId = 0L

  // Written from the main thread, read from the SDK's recording thread.
  @Volatile
  private var activeSessionId: Long? = null

  private var pendingPermission: ((Result<AcrCloudPermissionStatus>) -> Unit)? = null

  // region FlutterPlugin

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    AcrCloudHostApi.setUp(binding.binaryMessenger, this)
    RecognitionEventsStreamHandler.register(binding.binaryMessenger, events)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    AcrCloudHostApi.setUp(binding.binaryMessenger, null)
    releaseClient()
  }

  // endregion
  // region ActivityAware

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityBinding = binding
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
    onAttachedToActivity(binding)

  override fun onDetachedFromActivity() {
    // Removing the listener here is what the previous version forgot, which
    // leaked a listener and double-fired callbacks after a config change.
    activityBinding?.removeRequestPermissionsResultListener(this)
    activityBinding = null
  }

  override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

  // endregion
  // region AcrCloudHostApi

  override fun requestMicrophonePermission(
    callback: (Result<AcrCloudPermissionStatus>) -> Unit
  ) {
    if (hasPermission()) {
      callback(Result.success(AcrCloudPermissionStatus.GRANTED))
      return
    }

    val activity = this.activity
    if (activity == null) {
      callback(
        Result.failure(
          AcrCloudFlutterError(
            "NO_ACTIVITY",
            "Cannot request the microphone permission without an attached Activity.",
            null,
          )
        )
      )
      return
    }

    if (pendingPermission != null) {
      callback(
        Result.failure(
          AcrCloudFlutterError(
            "PERMISSION_REQUEST_IN_FLIGHT",
            "A microphone permission request is already in progress.",
            null,
          )
        )
      )
      return
    }

    pendingPermission = callback
    activity.requestPermissions(
      arrayOf(Manifest.permission.RECORD_AUDIO),
      PERMISSION_REQUEST_CODE,
    )
  }

  override fun configure(
    config: AcrCloudConfigMessage,
    callback: (Result<Unit>) -> Unit,
  ) {
    if (!hasPermission()) {
      callback(
        Result.failure(
          AcrCloudFlutterError("PERMISSION_DENIED", "Microphone permission is not granted.", null)
        )
      )
      return
    }

    releaseClient()

    val acrConfig = ACRCloudConfig().apply {
      acrcloudListener = Listener()
      context = this@FlutterAcrcloudPlugin.context
      accessKey = config.accessKey
      accessSecret = config.accessSecret
      host = config.host
      requestOnceTimeoutMS = config.requestTimeoutMs.toInt()
      recorderConfig.rate = 8000
      recorderConfig.channels = 1
      recorderConfig.isVolumeCallback = true
      protocol =
        if (config.useHttps) ACRCloudConfig.NetworkProtocol.HTTPS
        else ACRCloudConfig.NetworkProtocol.HTTP
    }

    val newClient = ACRCloudClient()

    // The previous version ignored this return value, so a failed init showed
    // up much later as an unrelated crash.
    if (!newClient.initWithConfig(acrConfig)) {
      newClient.release()
      callback(
        Result.failure(
          AcrCloudFlutterError(
            "INIT_FAILED",
            "The ACRCloud SDK failed to initialize. Check your credentials and host.",
            null,
          )
        )
      )
      return
    }

    client = newClient
    callback(Result.success(Unit))
  }

  override fun startRecognition(callback: (Result<Long>) -> Unit) {
    val client = this.client
    if (client == null) {
      callback(Result.failure(notConfigured()))
      return
    }

    if (activeSessionId != null) {
      callback(
        Result.failure(
          AcrCloudFlutterError("ALREADY_LISTENING", "A session is already running.", null)
        )
      )
      return
    }

    val id = ++sessionId
    activeSessionId = id

    if (!client.startRecognize()) {
      activeSessionId = null
      callback(
        Result.failure(
          AcrCloudFlutterError("START_FAILED", "The ACRCloud SDK failed to start recording.", null)
        )
      )
      return
    }

    callback(Result.success(id))
  }

  override fun cancelRecognition(sessionId: Long, callback: (Result<Unit>) -> Unit) {
    if (activeSessionId != sessionId) {
      callback(Result.success(Unit))
      return
    }

    activeSessionId = null
    // `cancel()` aborts. The previous version called `stopRecordToRecognize()`
    // here, which stops recording and then recognizes anyway.
    client?.cancel()
    callback(Result.success(Unit))
  }

  override fun stopAndRecognize(sessionId: Long, callback: (Result<Unit>) -> Unit) {
    if (activeSessionId != sessionId) {
      callback(Result.success(Unit))
      return
    }

    client?.stopRecordToRecognize()
    callback(Result.success(Unit))
  }

  override fun release(callback: (Result<Unit>) -> Unit) {
    releaseClient()
    callback(Result.success(Unit))
  }

  // endregion
  // region Permissions

  override fun onRequestPermissionsResult(
    requestCode: Int,
    permissions: Array<out String>,
    grantResults: IntArray,
  ): Boolean {
    if (requestCode != PERMISSION_REQUEST_CODE) return false

    val callback = pendingPermission ?: return true
    pendingPermission = null

    val granted =
      grantResults.isNotEmpty() && grantResults.first() == PackageManager.PERMISSION_GRANTED

    val status = when {
      granted -> AcrCloudPermissionStatus.GRANTED
      // After a denial, a false rationale means "don't ask again".
      activity?.shouldShowRequestPermissionRationale(Manifest.permission.RECORD_AUDIO) == false ->
        AcrCloudPermissionStatus.PERMANENTLY_DENIED
      else -> AcrCloudPermissionStatus.DENIED
    }

    callback(Result.success(status))
    return true
  }

  private fun hasPermission() =
    context.checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
      PackageManager.PERMISSION_GRANTED

  // endregion

  private fun notConfigured() =
    AcrCloudFlutterError(
      "NOT_CONFIGURED",
      "The ACRCloud client is not configured. Call configure() first.",
      null,
    )

  /** Releases the native client. The previous version never did this. */
  private fun releaseClient() {
    activeSessionId = null
    client?.release()
    client = null
  }

  private inner class Listener : IACRCloudListener {
    override fun onResult(result: ACRCloudResult?) {
      val id = activeSessionId ?: return
      activeSessionId = null

      val json = result?.result
      if (json == null) {
        events.emit(AcrCloudErrorEvent(id, "NO_RESULT", "The SDK returned an empty result."))
      } else {
        events.emit(AcrCloudResultEvent(id, json))
      }
    }

    override fun onVolumeChanged(volume: Double) {
      val id = activeSessionId ?: return
      events.emit(AcrCloudVolumeEvent(id, volume))
    }
  }
}
