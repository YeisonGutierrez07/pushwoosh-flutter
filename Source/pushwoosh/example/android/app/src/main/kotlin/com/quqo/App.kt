package com.quqo

import android.content.Context
import androidx.multidex.MultiDex
import io.flutter.app.FlutterApplication
import io.flutter.view.FlutterMain
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin

class App: FlutterApplication(), PluginRegistrantCallback  {

    override fun onCreate() {
        super.onCreate()
        FlutterMain.startInitialization(this)
        FlutterFirebaseMessagingService.setPluginRegistrant(this)
    }

    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)

        MultiDex.install(this)
    }

    @Override
    override fun registerWith(registry: PluginRegistry?) {
        if (!registry!!.hasPlugin("io.flutter.plugins.firebasemessaging")) {
            FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
        }
    }
}