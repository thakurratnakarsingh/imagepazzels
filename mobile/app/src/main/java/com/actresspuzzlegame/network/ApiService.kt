package com.actresspuzzlegame.network

import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Body
import retrofit2.http.Header

data class SplashData(
    val id: Int,
    val name: String,
    val image: String,
    val time: Int
)

data class AuthData(
    val accessToken: String,
    val refreshToken: String
)

data class GuestAuthResponse(
    val success: Boolean,
    val message: String?,
    val data: AuthData?
)

data class ActressData(
    val id: Int,
    val name: String,
    val thumbnail_image: String?,
    val is_active: Boolean
)

data class ActressesResponse(
    val success: Boolean,
    val data: List<ActressData>
)

data class GameLevelRequest(
    val level: Int,
    val actress_ids: List<Int>
)

data class LevelImageData(
    val id: Int,
    val actress_id: Int,
    val image_url: String
)

data class GameLevelResponse(
    val level: Int,
    val image: LevelImageData
)

interface ApiService {
    @GET("mobile/splash/active")
    suspend fun getActiveSplash(): Response<SplashData>

    @POST("mobile/auth/guest")
    suspend fun guestLogin(): Response<GuestAuthResponse>

    @GET("mobile/actresses")
    suspend fun getActresses(): Response<ActressesResponse>

    @POST("mobile/game/level-image")
    suspend fun getGameLevelImage(
        @Header("Authorization") authHeader: String,
        @Body request: GameLevelRequest
    ): Response<GameLevelResponse>
}
