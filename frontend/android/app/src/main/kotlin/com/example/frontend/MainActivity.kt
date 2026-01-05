package com.example.frontend

import android.speech.tts.TextToSpeech
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity: FlutterActivity(), TextToSpeech.OnInitListener {
    private val CHANNEL = "com.example.frontend/tts"
    private val TAG = "TTS_DEBUG"
    private var tts: TextToSpeech? = null
    private var ttsInitialized = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "🔧 Initializing TTS...")
        // Initialize TTS
        tts = TextToSpeech(this, this)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val language = call.argument<String>("language") ?: "ar"
                    val speechRate = call.argument<Double>("speechRate") ?: 0.8
                    
                    Log.d(TAG, "📌 Initialize called - ttsInitialized: $ttsInitialized")
                    
                    if (ttsInitialized) {
                        tts?.language = Locale(language)
                        tts?.setSpeechRate(speechRate.toFloat())
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "speak" -> {
                    val text = call.argument<String>("text") ?: ""
                    val language = call.argument<String>("language") ?: "ar"
                    
                    Log.d(TAG, "🎤 Speak called - ttsInitialized: $ttsInitialized, text length: ${text.length}")
                    
                    if (ttsInitialized && text.isNotEmpty()) {
                        // Try Arabic first
                        val arabicLocale = Locale("ar")
                        val langResult = tts?.setLanguage(arabicLocale)
                        Log.d(TAG, "🌍 Arabic language result: $langResult")
                        
                        // If Arabic not available, use default
                        if (langResult == TextToSpeech.LANG_MISSING_DATA || langResult == TextToSpeech.LANG_NOT_SUPPORTED) {
                            Log.d(TAG, "⚠️ Arabic not supported, using default locale")
                            tts?.setLanguage(Locale.getDefault())
                        }
                        
                        val speakResult = tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "tts_utterance")
                        Log.d(TAG, "🔊 Speak result: $speakResult")
                        
                        result.success(true)
                    } else {
                        Log.e(TAG, "❌ TTS not initialized or empty text")
                        result.error("TTS_ERROR", "TTS not initialized: $ttsInitialized, text empty: ${text.isEmpty()}", null)
                    }
                }
                "stop" -> {
                    Log.d(TAG, "⏹️ Stop called")
                    tts?.stop()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onInit(status: Int) {
        Log.d(TAG, "🚀 onInit called with status: $status (SUCCESS=0)")
        if (status == TextToSpeech.SUCCESS) {
            ttsInitialized = true
            Log.d(TAG, "✅ TTS initialized successfully!")
            
            // Check available languages
            val availableLocales = tts?.availableLanguages
            Log.d(TAG, "📋 Available languages: $availableLocales")
            
            // Set Arabic as default language
            val result = tts?.setLanguage(Locale("ar"))
            Log.d(TAG, "🌍 Set Arabic result: $result")
            
            if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
                Log.d(TAG, "⚠️ Arabic not supported, trying default")
                tts?.setLanguage(Locale.getDefault())
            }
            tts?.setSpeechRate(0.9f)
        } else {
            Log.e(TAG, "❌ TTS initialization failed with status: $status")
        }
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}
