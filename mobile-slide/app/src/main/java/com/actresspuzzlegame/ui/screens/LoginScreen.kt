package com.actresspuzzlegame.ui.screens

import android.content.Context
import android.provider.Settings
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.network.GuestAuthRequest
import com.actresspuzzlegame.ui.theme.PuzzleAqua
import com.actresspuzzlegame.ui.theme.PuzzleBackground
import com.actresspuzzlegame.ui.theme.PuzzleBlueDark
import com.actresspuzzlegame.ui.theme.PuzzleGold
import com.actresspuzzlegame.ui.theme.PuzzleOrange
import com.actresspuzzlegame.ui.theme.PuzzlePrimaryButton
import com.actresspuzzlegame.ui.theme.PuzzleTeal
import kotlinx.coroutines.launch

@Composable
fun LoginScreen(onLoginSuccess: () -> Unit) {
    val context = LocalContext.current
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    val coroutineScope = rememberCoroutineScope()
    val transition = rememberInfiniteTransition(label = "welcome_puzzle")
    val motion by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(1_400), repeatMode = RepeatMode.Reverse),
        label = "welcome_tile_motion"
    )

    fun loginAsGuest() {
        if (isLoading) return
        isLoading = true
        errorMessage = null
        coroutineScope.launch {
            try {
                val deviceId = Settings.Secure.getString(
                    context.contentResolver,
                    Settings.Secure.ANDROID_ID
                ) ?: "unknown-device"
                val response = ApiClient.service.guestLogin(GuestAuthRequest(deviceId))
                if (response.isSuccessful && response.body()?.success == true) {
                    val token = response.body()?.data?.accessToken.orEmpty()
                    context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
                        .edit()
                        .putString("auth_token", token)
                        .apply()
                    onLoginSuccess()
                } else {
                    errorMessage = "Login failed. Please try again."
                }
            } catch (_: Exception) {
                errorMessage = "Cannot reach the game server. Check your connection."
            } finally {
                isLoading = false
            }
        }
    }

    PuzzleBackground(Modifier.statusBarsPadding()) {
        Column(
            modifier = Modifier.fillMaxSize().padding(horizontal = 28.dp, vertical = 30.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text("IMAGE PUZZLE", color = Color.White, fontSize = 31.sp, fontWeight = FontWeight.Black)
            Text(
                "Drag. Swap. Complete.",
                color = Color.White.copy(alpha = 0.75f),
                fontSize = 15.sp
            )

            Spacer(Modifier.height(58.dp))
            Canvas(Modifier.size(265.dp)) {
                drawCircle(Color.White.copy(alpha = 0.12f), radius = size.minDimension * 0.52f)
                val gap = 8f
                val tileSize = (size.width - gap * 4) / 3f
                val colors = listOf(
                    PuzzleGold, PuzzleAqua, PuzzleTeal,
                    Color.White, PuzzleBlueDark, PuzzleOrange,
                    Color(0xFF9CEBE8), Color(0xFFFFE9A6), Color(0xFF78A8D8)
                )
                repeat(9) { position ->
                    val row = position / 3
                    val column = position % 3
                    val swapTarget = when (position) {
                        2 -> 6
                        6 -> 2
                        else -> position
                    }
                    val targetRow = swapTarget / 3
                    val targetColumn = swapTarget % 3
                    val topLeft = Offset(
                        x = gap + (column + (targetColumn - column) * motion) * (tileSize + gap),
                        y = gap + (row + (targetRow - row) * motion) * (tileSize + gap)
                    )
                    drawRoundRect(
                        color = colors[position],
                        topLeft = topLeft,
                        size = Size(tileSize, tileSize),
                        cornerRadius = androidx.compose.ui.geometry.CornerRadius(18f, 18f)
                    )
                }
            }

            Spacer(Modifier.height(34.dp))
            Text(
                "Build beautiful pictures\none tile at a time",
                color = Color.White,
                fontSize = 29.sp,
                lineHeight = 35.sp,
                fontWeight = FontWeight.ExtraBold,
                textAlign = TextAlign.Center
            )
            errorMessage?.let {
                Spacer(Modifier.height(14.dp))
                Text(it, color = Color(0xFFFFF59D), textAlign = TextAlign.Center)
            }

            Spacer(Modifier.weight(1f))
            PuzzlePrimaryButton(
                text = "LET'S PLAY  ▶",
                onClick = ::loginAsGuest,
                enabled = !isLoading,
                loading = isLoading
            )
        }
    }
}
