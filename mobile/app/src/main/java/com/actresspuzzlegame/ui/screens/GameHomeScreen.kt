package com.actresspuzzlegame.ui.screens

import android.content.Context
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.actresspuzzlegame.network.ActressData
import com.actresspuzzlegame.network.ApiClient
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import kotlin.math.cos
import kotlin.math.sin

@Composable
fun GameHomeScreen(
    actressIds: List<Int>,
    onStartGame: () -> Unit,
    onChangeModel: () -> Unit
) {
    val context = LocalContext.current
    val preferences = remember { context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE) }
    var currentLevel by remember { mutableIntStateOf(preferences.getInt("current_level", 1).coerceAtLeast(1)) }
    val lifecycleOwner = LocalLifecycleOwner.current
    var selectedModel by remember { mutableStateOf<ActressData?>(null) }
    var loading by remember { mutableStateOf(true) }

    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            if (event == Lifecycle.Event.ON_RESUME) {
                currentLevel = preferences.getInt("current_level", 1).coerceAtLeast(1)
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose { lifecycleOwner.lifecycle.removeObserver(observer) }
    }

    LaunchedEffect(actressIds) {
        loading = true
        selectedModel = runCatching {
            ApiClient.service.getActresses().body()?.data
                ?.firstOrNull { it.id in actressIds && it.is_active }
        }.getOrNull()
        loading = false
    }

    val transition = rememberInfiniteTransition(label = "home_animation")
    val pulse by transition.animateFloat(
        initialValue = 0.96f,
        targetValue = 1.04f,
        animationSpec = infiniteRepeatable(
            animation = tween(1_700),
            repeatMode = RepeatMode.Reverse
        ),
        label = "hero_pulse"
    )
    val bob by transition.animateFloat(
        initialValue = -8f,
        targetValue = 8f,
        animationSpec = infiniteRepeatable(
            animation = tween(2_000),
            repeatMode = RepeatMode.Reverse
        ),
        label = "hero_bob"
    )
    val orbit by transition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(animation = tween(8_000)),
        label = "sparkle_orbit"
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    listOf(Color(0xFF512DA8), Color(0xFF7B2CBF), Color(0xFFEE4B8B), Color(0xFFFF8A5B))
                )
            )
            .statusBarsPadding()
    ) {
        HomeBackgroundAnimation(orbit)

        Column(
            modifier = Modifier.fillMaxSize().padding(horizontal = 24.dp, vertical = 18.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("IMAGE", color = Color.White.copy(alpha = 0.75f), fontSize = 13.sp, fontWeight = FontWeight.Bold)
                    Text("PUZZLE", color = Color.White, fontSize = 28.sp, fontWeight = FontWeight.Black)
                }
                Spacer(Modifier.weight(1f))
                Box(
                    modifier = Modifier
                        .size(52.dp)
                        .shadow(10.dp, CircleShape)
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.22f))
                        .border(1.5.dp, Color.White.copy(alpha = 0.6f), CircleShape)
                        .clickable(onClick = onChangeModel),
                    contentAlignment = Alignment.Center
                ) {
                    Canvas(Modifier.size(29.dp)) {
                        drawCircle(Color.White, radius = size.minDimension * 0.22f, center = Offset(size.width / 2f, size.height * 0.27f))
                        drawCircle(Color.White, radius = size.minDimension * 0.42f, center = Offset(size.width / 2f, size.height * 0.94f))
                    }
                }
            }

            Spacer(Modifier.height(30.dp))
            Text(
                "READY TO PLAY?",
                color = Color(0xFFFFE36E),
                fontSize = 15.sp,
                fontWeight = FontWeight.ExtraBold,
                letterSpacing = 2.sp
            )
            Text(
                "Put the beauty\nback together",
                color = Color.White,
                fontSize = 34.sp,
                lineHeight = 39.sp,
                fontWeight = FontWeight.Black,
                textAlign = TextAlign.Center
            )

            Spacer(Modifier.height(28.dp))
            Box(
                modifier = Modifier
                    .size(246.dp)
                    .graphicsLayer {
                        scaleX = pulse
                        scaleY = pulse
                        translationY = bob
                    },
                contentAlignment = Alignment.Center
            ) {
                Box(
                    Modifier
                        .fillMaxSize()
                        .background(
                            Brush.radialGradient(listOf(Color(0xFFFFE36E), Color(0xFFFF8A5B))),
                            CircleShape
                        )
                )
                Box(
                    modifier = Modifier
                        .size(220.dp)
                        .shadow(22.dp, CircleShape)
                        .clip(CircleShape)
                        .background(Color(0xFF6536B9))
                        .border(5.dp, Color.White, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    when {
                        loading -> CircularProgressIndicator(color = Color.White)
                        selectedModel?.thumbnail_image != null -> AsyncImage(
                            model = "${ApiClient.BASE_SERVER_URL}uploads/actresses/thumbnails/${selectedModel?.thumbnail_image}",
                            contentDescription = selectedModel?.name,
                            contentScale = ContentScale.Crop,
                            modifier = Modifier.fillMaxSize()
                        )
                        else -> Text("✦", color = Color.White, fontSize = 92.sp)
                    }
                }
            }

            Spacer(Modifier.height(18.dp))
            Text(
                selectedModel?.name ?: "Your selected model",
                color = Color.White,
                fontSize = 22.sp,
                fontWeight = FontWeight.ExtraBold
            )
            Text(
                "Continue from Level $currentLevel",
                color = Color.White.copy(alpha = 0.78f),
                fontSize = 15.sp
            )

            Spacer(Modifier.weight(1f))
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(64.dp)
                    .shadow(16.dp, RoundedCornerShape(22.dp))
                    .clip(RoundedCornerShape(22.dp))
                    .background(
                        Brush.horizontalGradient(listOf(Color(0xFFFFE15D), Color(0xFFFF9F43)))
                    )
                    .clickable(enabled = actressIds.isNotEmpty(), onClick = onStartGame),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    "START GAME  ▶",
                    color = Color(0xFF4A2380),
                    fontSize = 21.sp,
                    fontWeight = FontWeight.Black
                )
            }
            Spacer(Modifier.height(12.dp))
            Text(
                "Tap the model icon to change your selection",
                color = Color.White.copy(alpha = 0.68f),
                fontSize = 12.sp
            )
        }
    }
}

@Composable
private fun HomeBackgroundAnimation(angle: Float) {
    Canvas(Modifier.fillMaxSize()) {
        drawCircle(Color.White.copy(alpha = 0.08f), radius = size.minDimension * 0.42f, center = Offset(0f, size.height * 0.28f))
        drawCircle(Color(0xFFFFE36E).copy(alpha = 0.13f), radius = size.minDimension * 0.34f, center = Offset(size.width, size.height * 0.72f))

        repeat(12) { index ->
            val radians = Math.toRadians((angle + index * 30f).toDouble())
            val center = Offset(
                x = size.width * 0.5f + cos(radians).toFloat() * size.width * 0.43f,
                y = size.height * 0.44f + sin(radians).toFloat() * size.height * 0.30f
            )
            drawCircle(
                color = if (index % 2 == 0) Color.White.copy(alpha = 0.45f) else Color(0xFFFFE36E).copy(alpha = 0.55f),
                radius = if (index % 3 == 0) 6f else 3.5f,
                center = center
            )
        }
    }
}
