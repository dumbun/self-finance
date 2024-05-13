package com.vamshikrishna.self_finance

import io.flutter.embedding.android.FlutterFragmentActivity

import android.view.WindowManager.LayoutParams
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    window.addFlags(LayoutParams.FLAG_SECURE)
    super.configureFlutterEngine(flutterEngine)
  }
}
