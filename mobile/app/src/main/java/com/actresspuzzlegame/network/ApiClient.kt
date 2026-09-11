package com.actresspuzzlegame.network

import com.actresspuzzlegame.BuildConfig
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

object ApiClient {
    val BASE_SERVER_URL: String = BuildConfig.API_BASE_URL.trimEnd('/') + "/"
    val BASE_URL: String = "${BASE_SERVER_URL}api/v1/"
    private val localServerUrl = Regex(
        pattern = "^https?://(?:localhost|127\\.0\\.0\\.1|0\\.0\\.0\\.0)(?::\\d+)?/?",
        option = RegexOption.IGNORE_CASE
    )

    private val httpClient by lazy {
        val logging = HttpLoggingInterceptor().apply {
            level = if (BuildConfig.DEBUG) {
                HttpLoggingInterceptor.Level.BASIC
            } else {
                HttpLoggingInterceptor.Level.NONE
            }
        }

        OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .addInterceptor(logging)
            .build()
    }

    val service: ApiService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(httpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(ApiService::class.java)
    }

    fun publicAssetUrl(pathOrUrl: String?): String? {
        val rawValue = pathOrUrl?.trim()?.takeIf { it.isNotEmpty() } ?: return null
        val normalizedValue = rawValue.replace('\\', '/')
        val publicValue = localServerUrl.replace(normalizedValue, BASE_SERVER_URL)

        if (publicValue.startsWith("http://", ignoreCase = true) ||
            publicValue.startsWith("https://", ignoreCase = true)
        ) {
            return publicValue
        }

        val uploadPath = publicValue
            .trimStart('/')
            .removePrefix("uploads/")

        return "${BASE_SERVER_URL}uploads/$uploadPath"
    }

    /** Kept for callers outside the app module that still build their own service. */
    fun getClient(): Retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .client(httpClient)
        .addConverterFactory(GsonConverterFactory.create())
        .build()
}
