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

data class GuestAuthRequest(
    val deviceId: String
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
    val image_url: String,
    val width: Int? = null,
    val height: Int? = null
)

data class GameLevelResponse(
    val level: Int,
    val level_id: Int? = null,
    val rows: Int? = null,
    val columns: Int? = null,
    val shuffle_moves: Int? = null,
    val max_moves_3_stars: Int? = null,
    val max_moves_2_stars: Int? = null,
    val reward_points: Int? = null,
    val session_id: String? = null,
    val saved_progress: SavedProgressData? = null,
    val image: LevelImageData
)

data class SavedProgressData(
    val tile_arrangement: List<Int>,
    val empty_tile_index: Int,
    val move_count: Int,
    val elapsed_time_seconds: Int
)

data class SaveProgressRequest(
    val levelId: Int,
    val sessionId: String,
    val tileArrangement: List<Int>,
    val emptyTileIndex: Int,
    val moveCount: Int,
    val elapsedTimeSeconds: Int
)

data class CompleteLevelRequest(
    val levelId: Int,
    val imageId: Int,
    val moves: Int,
    val timeTakenSeconds: Int,
    val puzzleSessionId: String
)

data class ApiMessageResponse(
    val success: Boolean,
    val message: String? = null
)

data class CompletionData(
    val rewardPointsEarned: Int = 0,
    val stars: Int = 1
)

data class CompleteLevelResponse(
    val success: Boolean,
    val message: String? = null,
    val data: CompletionData? = null
)

data class MobileConfigResponse(
    val success: Boolean,
    val data: Map<String, Any> = emptyMap()
)

data class PrivacyPolicyData(
    val version: String,
    val content: String,
    val published_at: String? = null
)

data class PrivacyPolicyResponse(
    val success: Boolean,
    val data: PrivacyPolicyData? = null
)

interface ApiService {
    @GET("mobile/splash/active")
    suspend fun getActiveSplash(): Response<SplashData>

    @POST("mobile/auth/guest")
    suspend fun guestLogin(@Body request: GuestAuthRequest): Response<GuestAuthResponse>

    @GET("mobile/actresses")
    suspend fun getActresses(): Response<ActressesResponse>

    @GET("mobile/config")
    suspend fun getMobileConfig(): Response<MobileConfigResponse>

    @GET("mobile/privacy-policy")
    suspend fun getPrivacyPolicy(): Response<PrivacyPolicyResponse>

    @POST("mobile/game/level-image")
    suspend fun getGameLevelImage(
        @Header("Authorization") authHeader: String,
        @Body request: GameLevelRequest
    ): Response<GameLevelResponse>

    @POST("mobile/game/progress")
    suspend fun saveProgress(
        @Header("Authorization") authHeader: String,
        @Body request: SaveProgressRequest
    ): Response<ApiMessageResponse>

    @POST("mobile/game/complete")
    suspend fun completeLevel(
        @Header("Authorization") authHeader: String,
        @Body request: CompleteLevelRequest
    ): Response<CompleteLevelResponse>
}
