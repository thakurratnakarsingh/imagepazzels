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
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.CircleShape
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
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.network.GuestAuthRequest
import com.actresspuzzlegame.ui.theme.PremiumAccent
import com.actresspuzzlegame.ui.theme.PremiumBackgroundDark
import com.actresspuzzlegame.ui.theme.PremiumGold
import com.actresspuzzlegame.ui.theme.PremiumGoldLight
import com.actresspuzzlegame.ui.theme.PremiumPrimary
import com.actresspuzzlegame.ui.theme.PremiumPrimaryLight
import com.actresspuzzlegame.ui.theme.PremiumSurface
import com.actresspuzzlegame.ui.theme.PremiumSurfaceHighlight
import com.actresspuzzlegame.ui.theme.PremiumTextDark
import com.actresspuzzlegame.ui.theme.PremiumTextGray
import com.actresspuzzlegame.ui.theme.PremiumTextWhite
import com.actresspuzzlegame.ui.theme.PremiumWarning
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
        animationSpec = infiniteRepeatable(tween(1_450), repeatMode = RepeatMode.Reverse),
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

    PremiumGameBackground(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 28.dp, vertical = 28.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            PremiumLogo(titleSize = 24, subtitle = "Slide | Solve | Celebrate")

            Spacer(Modifier.height(46.dp))
            LoginPuzzleHero(motion = motion)

            Spacer(Modifier.height(30.dp))
            Text(
                text = "Build beautiful pictures\none tile at a time",
                color = PremiumTextWhite,
                fontSize = 29.sp,
                lineHeight = 34.sp,
                fontWeight = FontWeight.Black,
                textAlign = TextAlign.Center
            )
            Text(
                text = "Relaxing sliding puzzles with saved progress and rewards.",
                color = PremiumTextGray,
                fontSize = 14.sp,
                lineHeight = 19.sp,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 8.dp)
            )

            errorMessage?.let {
                Spacer(Modifier.height(14.dp))
                PremiumPanel(shape = androidx.compose.foundation.shape.RoundedCornerShape(16.dp), elevated = false) {
                    Text(
                        text = it,
                        color = PremiumWarning,
                        textAlign = TextAlign.Center,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)
                    )
                }
            }

            Spacer(Modifier.weight(1f))
            PremiumGameButton(
                text = "LET'S PLAY",
                onClick = ::loginAsGuest,
                loading = isLoading,
                icon = GameIcon.Play,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(64.dp),
                primaryColor = PremiumGoldLight,
                secondaryColor = PremiumGold,
                textColor = PremiumTextDark
            )
        }
    }
}

@Composable
private fun LoginPuzzleHero(motion: Float) {
    Box(
        modifier = Modifier
            .size(268.dp)
            .clip(CircleShape)
            .background(
                Brush.radialGradient(
                    listOf(
                        PremiumSurfaceHighlight.copy(alpha = 0.82f),
                        PremiumBackgroundDark.copy(alpha = 0.15f)
                    )
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Canvas(Modifier.size(236.dp)) {
            val gap = 8f
            val tileSize = (size.width - gap * 4) / 3f
            val colors = listOf(
                PremiumPrimaryLight,
                PremiumAccent,
                PremiumPrimary,
                PremiumGoldLight,
                PremiumTextWhite,
                PremiumSurfaceHighlight,
                PremiumGold,
                PremiumSurface
            )
            drawRoundRect(
                color = PremiumBackgroundDark.copy(alpha = 0.48f),
                topLeft = Offset(0f, 0f),
                size = size,
                cornerRadius = CornerRadius(30f, 30f)
            )
            drawRoundRect(
                color = Color.White.copy(alpha = 0.10f),
                topLeft = Offset(5f, 4f),
                size = Size(size.width - 10f, size.height - 10f),
                cornerRadius = CornerRadius(26f, 26f),
                style = Stroke(width = 3f)
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
                        color = Color.Black.copy(alpha = 0.22f),
                        topLeft = topLeft + Offset(0f, 7f),
                        size = Size(tileSize, tileSize),
                        cornerRadius = CornerRadius(18f, 18f)
                    )
                    drawRoundRect(
                        color = colors[colorIndex++ % colors.size],
                        topLeft = topLeft,
                        size = Size(tileSize, tileSize),
                        cornerRadius = CornerRadius(18f, 18f)
                    )
                    drawRoundRect(
                        color = Color.White.copy(alpha = 0.24f),
                        topLeft = topLeft + Offset(5f, 5f),
                        size = Size(tileSize - 10f, tileSize * 0.32f),
                        cornerRadius = CornerRadius(12f, 12f)
                    )
                }
            }
        }
    }
}
