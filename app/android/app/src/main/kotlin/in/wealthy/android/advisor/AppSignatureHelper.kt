package `in`.wealthy.android.advisor

import android.content.Context
import android.content.pm.PackageManager
import android.content.pm.PackageInfo
import android.content.pm.Signature
import android.util.Base64
import android.util.Log
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

object AppSignatureHelper {
    fun printHashKey(context: Context) {
        try {
            val info: PackageInfo = context.packageManager.getPackageInfo(
                context.packageName,
                PackageManager.GET_SIGNATURES
            )
            info.signatures?.forEach { signature ->
                val md = MessageDigest.getInstance("SHA")
                md.update(signature.toByteArray())
                val hash = Base64.encodeToString(md.digest(), Base64.NO_WRAP)
                    .substring(0, 11)
                Log.e("AppHashKey", "HashKey: $hash")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}