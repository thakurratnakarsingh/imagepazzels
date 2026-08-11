package com.actresspuzzlegame.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.network.SplashData
import com.actresspuzzlegame.ui.theme.PuzzleAqua
import com.actresspuzzlegame.ui.theme.PuzzleBackground
import com.actresspuzzlegame.ui.theme.PuzzleGold
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(onSplashComplete: () -> Unit) {
    var splashData by remember { mutableStateOf<SplashData?>(null) }
    var isLoading by remember { mutableStateOf(true) }

    LaunchedEffect(Unit) {
        splashData = runCatching {
            ApiClient.service.getActiveSplash().body()
        }.getOrNull()
        isLoading = false
        delay(((splashData?.time ?: 3) * 1_000L).coerceAtLeast(1_000L))
        onSplashComplete()
    }

    PuzzleBackground(Modifier.statusBarsPadding()) {
        splashData?.let { data ->
            AsyncImage(
                model = data.image,
                contentDescription = data.name,
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )
            Box(
                Modifier
                    .fillMaxSize()
                    .background(
                        Brush.verticalGradient(
                            listOf(
                                Color(0x552B689E),
                                Color.Transparent,
                                Color(0xDD284E80)
                            )
                        )
                    )
            )
        }

        Column(
            modifier = Modifier.fillMaxSize().padding(horizontal = 24.dp, vertical = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(66.dp)
                    .border(2.dp, Color.White.copy(alpha = 0.78f), RoundedCornerShape(20.dp))
                    .background(Color(0x663469A0), RoundedCornerShape(20.dp)),
                contentAlignment = Alignment.Center
            ) {
                Text("▦", color = PuzzleAqua, fontSize = 37.sp, fontWeight = FontWeight.Black)
            }
            Spacer(Modifier.weight(1f))
            Text(
                "IMAGE PUZZLE",
                color = Color.White,
                fontSize = 31.sp,
                letterSpacing = 1.5.sp,
                fontWeight = FontWeight.Black
            )
            Text(
                "Drag • Swap • Complete",
                modifier = Modifier.fillMaxWidth(),
                color = PuzzleGold,
                fontSize = 15.sp,
                fontWeight = FontWeight.Bold,
                textAlign = TextAlign.Center
            )
            if (isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.padding(top = 18.dp).size(27.dp),
                    color = PuzzleAqua,
                    strokeWidth = 3.dp
                )
            } else {
                Spacer(Modifier.size(45.dp))
            }
        }
    }
}
