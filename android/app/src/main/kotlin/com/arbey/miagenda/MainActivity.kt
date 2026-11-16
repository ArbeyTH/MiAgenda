
package com.arbey.miagenda

import android.util.Log
import com.google.android.libraries.ads.mobile.sdk.MobileAds
import com.google.android.libraries.ads.mobile.sdk.initialization.InitializationConfig
import com.google.android.libraries.ads.mobile.sdk.common.AdLoadCallback
import com.google.android.libraries.ads.mobile.sdk.common.AdValue
import com.google.android.libraries.ads.mobile.sdk.common.ExperimentalApi
import com.google.android.libraries.ads.mobile.sdk.common.FullScreenContentError
import com.google.android.libraries.ads.mobile.sdk.common.LoadAdError
import com.google.android.libraries.ads.mobile.sdk.pip.PictureInPictureAd
import com.google.android.libraries.ads.mobile.sdk.pip.PictureInPictureAdEventCallback
import com.google.android.libraries.ads.mobile.sdk.pip.PictureInPictureAdOptions
import com.google.android.libraries.ads.mobile.sdk.pip.PictureInPictureAdRequest
import com.google.android.libraries.ads.mobile.sdk.pip.PictureInPictureAdPresentationScope
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

@OptIn(ExperimentalApi::class)
class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.arbey.miagenda/pip"
        private const val TAG = "MiAgendaPiP"

        // ID de aplicación de prueba de Google.
        private const val TEST_APP_ID =
            "ca-app-pub-3940256099942544~3347511713"

        // ID específico del anuncio PiP de prueba.
        private const val TEST_AD_UNIT_ID =
            "ca-app-pub-3940256099942544/9657123429"
    }

    private var sdkInitialized = false
    private var pipAd: PictureInPictureAd? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "loadAndShowPipAd" -> {
                    loadAndShowPipAd(result)
                }

                "hidePipAd" -> {
                    val ad = pipAd

                    if (ad != null) {
                        runOnUiThread {
                            ad.hide()
                            result.success(true)
                        }
                    } else {
                        result.success(false)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }

        initializeGmaSdk()
    }

    private fun initializeGmaSdk() {
        if (sdkInitialized) return

        Thread {
            MobileAds.initialize(
                this@MainActivity,
                InitializationConfig.Builder(TEST_APP_ID).build()
            ) {
                runOnUiThread {
                    sdkInitialized = true
                    Log.d(TAG, "Google Ads SDK inicializado correctamente.")
                }
            }
        }.start()
    }

    private fun loadAndShowPipAd(
        result: MethodChannel.Result
    ) {
        if (!sdkInitialized) {
            result.error(
                "SDK_NOT_READY",
                "Google Ads todavía se está inicializando. Intenta nuevamente.",
                null
            )
            return
        }

        val request = PictureInPictureAdRequest.Builder(
            TEST_AD_UNIT_ID
        ).build()

        PictureInPictureAd.load(
            request,
            object : AdLoadCallback<PictureInPictureAd> {

                override fun onAdLoaded(ad: PictureInPictureAd) {
                    Log.d(TAG, "Anuncio PiP cargado correctamente.")

                    pipAd?.destroy()
                    pipAd = ad

                    setAdEventCallback(ad)

                    runOnUiThread {
                        val options =
                            PictureInPictureAdOptions.Builder()
                                .setPresentationScope(
                                    PictureInPictureAdPresentationScope.SCREEN
                                )
                                .build()

                        ad.show(this@MainActivity, options)

                        result.success(
                            "Anuncio PiP cargado y mostrado."
                        )
                    }
                }

                override fun onAdFailedToLoad(
                    adError: LoadAdError
                ) {
                    Log.e(TAG, "Error al cargar anuncio: $adError")

                    runOnUiThread {
                        result.error(
                            "AD_LOAD_FAILED",
                            adError.toString(),
                            null
                        )
                    }
                }
            }
        )
    }

    private fun setAdEventCallback(ad: PictureInPictureAd) {
        ad.adEventCallback =
            object : PictureInPictureAdEventCallback {

                override fun onAdShown() {
                    Log.d(TAG, "Anuncio PiP mostrado.")
                }

                override fun onAdHidden() {
                    Log.d(TAG, "Anuncio PiP ocultado.")
                }

                override fun onAdImpression() {
                    Log.d(TAG, "Impresión del anuncio registrada.")
                }

                override fun onAdClicked() {
                    Log.d(TAG, "Clic en el anuncio.")
                }

                override fun onAdShowedFullScreenContent() {
                    Log.d(TAG, "Contenido de pantalla completa mostrado.")
                }

                override fun onAdDismissedFullScreenContent() {
                    Log.d(TAG, "Contenido de pantalla completa cerrado.")
                }

                override fun onAdFailedToShowFullScreenContent(
                    fullScreenContentError: FullScreenContentError
                ) {
                    Log.e(
                        TAG,
                        "Error al mostrar anuncio: $fullScreenContentError"
                    )
                }

                override fun onAdPaid(value: AdValue) {
                    Log.d(TAG, "Evento de pago del anuncio.")
                }
            }
    }

    override fun onDestroy() {
        pipAd?.destroy()
        pipAd = null
        super.onDestroy()
    }
}
