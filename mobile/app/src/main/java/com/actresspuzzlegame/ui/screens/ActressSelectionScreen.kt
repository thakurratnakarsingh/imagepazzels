package com.actresspuzzlegame.ui.screens

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.actresspuzzlegame.network.ActressData
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.ui.theme.BrandCream
import com.actresspuzzlegame.ui.theme.BrandGold
import com.actresspuzzlegame.ui.theme.BrandGradientColors
import com.actresspuzzlegame.ui.theme.BrandInk
import com.actresspuzzlegame.ui.theme.BrandMuted
import com.actresspuzzlegame.ui.theme.BrandPurple
import com.actresspuzzlegame.ui.theme.BrandPurpleDark

@Composable
fun ActressSelectionScreen(
    initialSelectedIds: Set<Int> = emptySet(),
    onSelectionConfirmed: (List<Int>) -> Unit
) {
    var actresses by remember { mutableStateOf<List<ActressData>>(emptyList()) }
    var selectedActressIds by remember(initialSelectedIds) { mutableStateOf(initialSelectedIds) }
    var isLoading by remember { mutableStateOf(true) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(Unit) {
        try {
            val response = ApiClient.service.getActresses()
            if (response.isSuccessful && response.body()?.success == true) {
                actresses = response.body()?.data?.filter { it.is_active }.orEmpty()
            } else {
                errorMessage = "Models could not be loaded"
            }
        } catch (_: Exception) {
            errorMessage = "Cannot reach the game server"
        } finally {
            isLoading = false
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(BrandGradientColors))
            .statusBarsPadding()
    ) {
        Canvas(Modifier.fillMaxSize()) {
            drawCircle(Color.White.copy(alpha = 0.08f), size.minDimension * 0.42f, Offset(0f, size.height * 0.22f))
            drawCircle(BrandGold.copy(alpha = 0.12f), size.minDimension * 0.34f, Offset(size.width, size.height * 0.78f))
        }

        Column(Modifier.fillMaxSize()) {
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 22.dp, vertical = 18.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text("CHOOSE YOUR MODELS", color = Color.White, fontSize = 25.sp, fontWeight = FontWeight.Black)
                    Text(
                        "Every level picks from your favourites",
                        color = Color.White.copy(alpha = 0.72f),
                        fontSize = 13.sp
                    )
                }
                Surface(
                    color = Color.White.copy(alpha = 0.20f),
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier.border(1.dp, Color.White.copy(alpha = 0.35f), RoundedCornerShape(16.dp))
                ) {
                    Text(
                        "${selectedActressIds.size} selected",
                        color = Color.White,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 9.dp)
                    )
                }
            }

            Box(modifier = Modifier.fillMaxWidth().weight(1f)) {
                when {
                    isLoading -> CircularProgressIndicator(
                        color = BrandGold,
                        modifier = Modifier.align(Alignment.Center)
                    )
                    errorMessage != null -> Text(
                        errorMessage.orEmpty(),
                        color = Color.White,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.align(Alignment.Center).padding(24.dp)
                    )
                    actresses.isEmpty() -> Text(
                        "No models are available yet",
                        color = Color.White,
                        modifier = Modifier.align(Alignment.Center)
                    )
                    else -> LazyColumn(
                        contentPadding = PaddingValues(horizontal = 18.dp, vertical = 8.dp),
                        verticalArrangement = Arrangement.spacedBy(11.dp),
                        modifier = Modifier.fillMaxSize()
                    ) {
                        items(actresses, key = { it.id }) { actress ->
                            val selected = actress.id in selectedActressIds
                            Surface(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .shadow(if (selected) 13.dp else 5.dp, RoundedCornerShape(20.dp))
                                    .border(
                                        width = if (selected) 3.dp else 1.dp,
                                        color = if (selected) BrandGold else Color.White.copy(alpha = 0.35f),
                                        shape = RoundedCornerShape(20.dp)
                                    )
                                    .clickable {
                                        selectedActressIds = if (selected) {
                                            selectedActressIds - actress.id
                                        } else {
                                            selectedActressIds + actress.id
                                        }
                                    },
                                color = if (selected) Color(0xFFF4E9FF) else BrandCream.copy(alpha = 0.94f),
                                shape = RoundedCornerShape(20.dp)
                            ) {
                                Row(
                                    modifier = Modifier.padding(12.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .size(66.dp)
                                            .clip(CircleShape)
                                            .background(BrandPurple)
                                            .border(3.dp, if (selected) BrandGold else Color.White, CircleShape),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        if (actress.thumbnail_image != null) {
                                            AsyncImage(
                                                model = "${ApiClient.BASE_SERVER_URL}uploads/actresses/thumbnails/${actress.thumbnail_image}",
                                                contentDescription = actress.name,
                                                modifier = Modifier.fillMaxSize(),
                                                contentScale = ContentScale.Crop
                                            )
                                        } else {
                                            Text("✦", color = Color.White, fontSize = 28.sp)
                                        }
                                    }
                                    Spacer(Modifier.width(14.dp))
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text(actress.name, color = BrandInk, fontSize = 18.sp, fontWeight = FontWeight.ExtraBold)
                                        Text(
                                            if (selected) "Included in your puzzle mix" else "Tap to add to your mix",
                                            color = BrandMuted,
                                            fontSize = 12.sp
                                        )
                                    }
                                    Box(
                                        modifier = Modifier
                                            .size(32.dp)
                                            .clip(CircleShape)
                                            .background(if (selected) BrandPurple else Color(0xFFE7DFED))
                                            .border(1.dp, if (selected) BrandPurpleDark else Color(0xFFC8BBD1), CircleShape),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        if (selected) Text("✓", color = Color.White, fontWeight = FontWeight.Black)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 18.dp, vertical = 14.dp)
                    .height(62.dp)
                    .shadow(16.dp, RoundedCornerShape(21.dp))
                    .clip(RoundedCornerShape(21.dp))
                    .background(
                        if (selectedActressIds.isNotEmpty()) {
                            Brush.horizontalGradient(listOf(BrandGold, Color(0xFFFFA443)))
                        } else {
                            Brush.horizontalGradient(listOf(Color(0xFFB9A8C7), Color(0xFFA590B4)))
                        }
                    )
                    .clickable(enabled = selectedActressIds.isNotEmpty()) {
                        onSelectionConfirmed(selectedActressIds.toList())
                    },
                contentAlignment = Alignment.Center
            ) {
                Text(
                    if (selectedActressIds.isEmpty()) "SELECT AT LEAST ONE" else "CONTINUE WITH ${selectedActressIds.size}  ▶",
                    color = if (selectedActressIds.isNotEmpty()) BrandPurpleDark else Color.White.copy(alpha = 0.8f),
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Black
                )
            }
        }
    }
}
