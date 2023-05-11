package com.outsystems.plugin.urbimaps

import android.content.Intent
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaInterface
import org.apache.cordova.CordovaPlugin
import org.apache.cordova.CordovaWebView
import org.json.JSONArray
import ru.dgis.sdk.Context
import ru.dgis.sdk.DGis
import ru.dgis.sdk.LogLevel
import ru.dgis.sdk.LogOptions
import ru.dgis.sdk.positioning.registerPlatformLocationSource
import ru.dgis.sdk.positioning.registerPlatformMagneticSource
import java.lang.Exception

private const val ACTION_OPEN_MAPS = "openMap"

class UrbiMaps : CordovaPlugin() {

  lateinit var sdkContext: Context

  override fun initialize(cordova: CordovaInterface?, webView: CordovaWebView?) {
    super.initialize(cordova, webView)
    sdkContext = initializeDGis(this.cordova.context)

    if (this::sdkContext.isInitialized) {
      SdkContext.context = sdkContext
    }

    registerServices()
  }

  override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
    try {
      if (ACTION_OPEN_MAPS == action) {
        this.cordova.activity.startActivity(Intent(this.cordova.context, MainMapsActivity::class.java))
        callbackContext.success()
      } else {
        callbackContext.error("Action $action not found!")
      }
    } catch (ex: Exception) {
        callbackContext.error(ex.message)
    }

    return true
  }

  private fun registerServices() {
    val compassSource = CustomCompassManager(this.cordova.context)
    registerPlatformMagneticSource(sdkContext, compassSource)

    val locationSource = CustomLocationManager(this.cordova.context)
    registerPlatformLocationSource(sdkContext, locationSource)
  }

  private fun initializeDGis(appContext: android.content.Context): Context {
    return DGis.initialize(
      appContext,
      logOptions = LogOptions(
        customLevel = LogLevel.WARNING,
        customSink = null
      )
    )
  }
}