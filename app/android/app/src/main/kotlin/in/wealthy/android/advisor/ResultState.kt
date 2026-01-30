package `in`.wealthy.android.advisor

import io.flutter.plugin.common.MethodChannel

class ResultState {
    var methodResult: MethodChannel.Result? = null

    companion object {
        val instance = ResultState()
    }
}