package com.example.finpet

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        dismissSystemSplash()
    }

    override fun onPostResume() {
        super.onPostResume()
        dismissSystemSplash()
    }

    private fun dismissSystemSplash() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
        splashScreen.setOnExitAnimationListener { view -> view.remove() }
    }
}
