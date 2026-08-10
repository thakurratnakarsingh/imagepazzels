package com.actresspuzzlegame.ui.screens

import android.content.Context
import android.provider.Settings
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.network.GuestAuthRequest
import com.actresspuzzlegame.ui.theme.BrandGradientColors
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

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(BrandGradientColors)
            )
            .statusBarsPadding()
    ) {
        Column(
            modifier = Modifier.fillMaxSize().padding(horizontal = 28.dp, vertical = 30.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text("IMAGE PUZZLE", color = Color.White, fontSize = 31.sp, fontWeight = FontWeight.Black)
            Text(
                "Slide. Solve. Celebrate.",
                color = Color.White.copy(alpha = 0.75f),
                fontSize = 15.sp
            )

            Spacer(Modifier.height(58.dp))
            Canvas(Modifier.size(265.dp)) {
                drawCircle(Color.White.copy(alpha = 0.12f), radius = size.minDimension * 0.52f)
                val gap = 8f
                val tileSize = (size.width - gap * 4) / 3f
                val colors = listOf(
                    Color(0xFFFFD740), Color(0xFF40C4FF), Color(0xFFFF4081),
                    Color(0xFF69F0AE), Color.White, Color(0xFFFF8A65),
                    Color(0xFFB388FF), Color(0xFFFFD180)
                )
                var colorIndex = 0
                for (row in 0..2) {
                    for (column in 0..2) {
                        if (row == 1 && column == 2) continue
                        val extraX = if (row == 2 && column == 2) -tileSize * 0.22f * motion else 0f
                        val extraY = if (row == 2 && column == 2) -tileSize * 0.72f * motion else 0f
                        val topLeft = Offset(
                            gap + column * (tileSize + gap) + extraX,
                            gap + row * (tileSize + gap) + extraY
                        )
                        drawRoundRect(
                            color = colors[colorIndex++ % colors.size],
                            topLeft = topLeft,
                            size = Size(tileSize, tileSize),
                            cornerRadius = androidx.compose.ui.geometry.CornerRadius(18f, 18f)
                        )
                    }
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
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(64.dp)
                    .shadow(16.dp, RoundedCornerShape(22.dp))
                    .clip(RoundedCornerShape(22.dp))
                    .background(Brush.horizontalGradient(listOf(Color(0xFFFFE15D), Color(0xFFFFA443))))
                    .clickable(enabled = !isLoading, onClick = ::loginAsGuest),
                contentAlignment = Alignment.Center
            ) {
                if (isLoading) {
                    CircularProgressIndicator(color = Color(0xFF4A2380), modifier = Modifier.size(28.dp))
                } else {
                    Text("LET'S PLAY  ▶", color = Color(0xFF4A2380), fontSize = 21.sp, fontWeight = FontWeight.Black)
                }
            }
        }
    }
}
