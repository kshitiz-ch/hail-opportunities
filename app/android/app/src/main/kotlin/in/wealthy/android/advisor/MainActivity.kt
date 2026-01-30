package `in`.wealthy.android.advisor

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.freshchat.consumer.sdk.flutter.FreshchatSdkPlugin
import com.google.android.gms.auth.api.identity.GetPhoneNumberHintIntentRequest
import com.google.android.gms.auth.api.identity.Identity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL: String = "in.wealthy.advisor"
    private val PHONE_HINT_REQUEST_CODE: Int = 1002
    private var methodResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        flutterEngine.plugins.add(FreshchatSdkPlugin())

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                // Note: this method is invoked on the main thread.
                call,
                result ->
        if (call.method == "getPhoneNumberHint") {
                getPhoneNumberHint(result)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        try {
            super.onActivityResult(requestCode, resultCode, data)

            Log.d("TAG", "onActivityResult: $requestCode, $resultCode, $data")

            when (requestCode) {
                
                PHONE_HINT_REQUEST_CODE -> {
                    if (resultCode == Activity.RESULT_OK && data != null) {
                        try {
                            val phoneNumber = Identity.getSignInClient(this).getPhoneNumberFromIntent(data)
                            Log.d("MainActivity", "Phone hint received: $phoneNumber")
                            methodResult?.success(phoneNumber ?: "")
                        } catch (e: Exception) {
                            Log.e("MainActivity", "Error extracting phone from intent: ${e.message}")
                            methodResult?.success("")
                        }
                    } else {
                        Log.d("MainActivity", "Phone hint dialog cancelled or no data")
                        methodResult?.success("")
                    }
                    methodResult = null
                }
                // Other result codes
                else -> {}
            }
        } catch (e: Exception) {
            Log.d("TAG", "Error in onActivityResult $e")
        }
    }

    private fun getPhoneNumberHint(result: MethodChannel.Result) {
        try {
            methodResult = result
            val request = GetPhoneNumberHintIntentRequest.builder().build()
            
            Identity.getSignInClient(this)
                .getPhoneNumberHintIntent(request)
                .addOnSuccessListener { intentSender ->
                    try {
                        startIntentSenderForResult(
                            intentSender.intentSender,
                            PHONE_HINT_REQUEST_CODE,
                            null, 0, 0, 0
                        )
                    } catch (e: Exception) {
                        Log.e("MainActivity", "Error starting phone hint intent: ${e.message}")
                        result.success("")
                    }
                }
                .addOnFailureListener { e ->
                    Log.e("MainActivity", "Error getting phone hint intent: ${e.message}")
                    result.success("")
                }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error in getPhoneNumberHint: ${e.message}")
            result.success("")
        }
    }

   
    override fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<String>,
            grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1) {
            if (grantResults.size == 5 &&
                            grantResults[0] == PackageManager.PERMISSION_GRANTED &&
                            grantResults[1] == PackageManager.PERMISSION_GRANTED &&
                            grantResults[2] == PackageManager.PERMISSION_GRANTED &&
                            grantResults[3] == PackageManager.PERMISSION_GRANTED &&
                            grantResults[4] == PackageManager.PERMISSION_GRANTED
            ) {
                Log.d("Wealthy", "all the required permissions are granted")
                methodResult!!.success("success")
            } else {
                Log.d("Wealthy", "all the required permissions are not granted")
                methodResult!!.success("failure")
            }
        }
    }
}
