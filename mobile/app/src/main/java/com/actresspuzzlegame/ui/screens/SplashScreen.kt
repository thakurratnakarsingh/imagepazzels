package com.actresspuzzlegame.ui.screens

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.network.SplashData
import com.actresspuzzlegame.ui.theme.BrandGold
import com.actresspuzzlegame.ui.theme.BrandGradientColors
import com.actresspuzzlegame.ui.theme.BrandPurpleDark
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(onSplashComplete: () -> Unit) {
    val splashData = remember { mutableStateOf<SplashData?>(null) }
    val isLoading = remember { mutableStateOf(true) }
    val transition = rememberInfiniteTransition(label = "splash_pulse")
    val pulse by transition.animateFloat(
        initialValue = 0.92f,
        targetValue = 1.08f,
        animationSpec = infiniteRepeatable(tween(1_200), repeatMode = RepeatMode.Reverse),
        label = "splash_logo_pulse"
    )

    LaunchedEffect(Unit) {
        try {
            val response = ApiClient.service.getActiveSplash()
            if (response.isSuccessful) splashData.value = response.body()
        } catch (_: Exception) {
            // The branded fallback remains visible when the device is offline.
        } finally {
            isLoading.value = false
        }
        delay(((splashData.value?.time ?: 3) * 1_000L))
        onSplashComplete()
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(BrandGradientColors))
            .statusBarsPadding()
    ) {
        splashData.value?.let { data ->
            AsyncImage(
                model = data.image,
                contentDescription = data.name,
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )
            Box(
                Modifier.fillMaxSize().background(
                    Brush.verticalGradient(
                        listOf(Color.Transparent, Color.Transparent, BrandPurpleDark.copy(alpha = 0.92f))
                    )
                )
            )
        }

        Column(
            modifier = Modifier.fillMaxSize().padding(horizontal = 28.dp, vertical = 42.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(Modifier.weight(1f))
            Box(
                modifier = Modifier
                    .size(82.dp)
                    .graphicsLayer { scaleX = pulse; scaleY = pulse }
                    .clip(CircleShape)
                    .background(BrandGold),
                contentAlignment = Alignment.Center
            ) {
                Text("✦", color = BrandPurpleDark, fontSize = 42.sp, fontWeight = FontWeight.Black)
            }
            Text(
                "IMAGE PUZZLE",
                color = Color.White,
                fontSize = 30.sp,
                fontWeight = FontWeight.Black,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 14.dp)
            )
            Text(
                "Slide • Solve • Celebrate",
                color = Color.White.copy(alpha = 0.76f),
                fontSize = 14.sp,
                letterSpacing = 1.sp
            )
            if (isLoading.value) {
                CircularProgressIndicator(
                    color = BrandGold,
                    strokeWidth = 3.dp,
                    modifier = Modifier.padding(top = 24.dp).size(28.dp)
                )
            } else {
                Spacer(Modifier.size(52.dp))
            }
        }
    }
}
