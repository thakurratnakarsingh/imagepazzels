package com.actresspuzzlegame.ui.screens

import android.content.Context
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import coil.compose.AsyncImage
import com.actresspuzzlegame.network.ActressData
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.ui.theme.PuzzleAqua
import com.actresspuzzlegame.ui.theme.PuzzleBackground
import com.actresspuzzlegame.ui.theme.PuzzleGold
import com.actresspuzzlegame.ui.theme.PuzzleNavy
import com.actresspuzzlegame.ui.theme.PuzzlePrimaryButton
import com.actresspuzzlegame.ui.theme.PuzzleTeal

@Composable
fun GameHomeScreen(
    actressIds: List<Int>,
    onStartGame: () -> Unit,
    onChangeModel: () -> Unit
) {
    val context = LocalContext.current
    val preferences = remember { context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE) }
    var currentLevel by remember {
        mutableIntStateOf(preferences.getInt("current_level", 1).coerceAtLeast(1))
    }
    val lifecycleOwner = LocalLifecycleOwner.current
    var selectedModels by remember { mutableStateOf<List<ActressData>>(emptyList()) }
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
        selectedModels = runCatching {
            val modelsById = ApiClient.service.getActresses().body()?.data
                .orEmpty()
                .filter { it.is_active }
                .associateBy { it.id }
            actressIds
                .take(MAX_SELECTED_MODELS)
                .mapNotNull(modelsById::get)
        }.getOrDefault(emptyList())
        loading = false
    }

    val transition = rememberInfiniteTransition(label = "model_showcase")
    val pulse by transition.animateFloat(
        initialValue = 0.99f,
        targetValue = 1.01f,
        animationSpec = infiniteRepeatable(
            animation = tween(1_800),
            repeatMode = RepeatMode.Reverse
        ),
        label = "showcase_pulse"
    )

    PuzzleBackground(Modifier.statusBarsPadding()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 20.dp, vertical = 14.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(50.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .border(1.5.dp, Color.White.copy(alpha = 0.55f), RoundedCornerShape(16.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Text("▦", color = PuzzleAqua, fontSize = 28.sp, fontWeight = FontWeight.Black)
                }
                Spacer(Modifier.width(11.dp))
                Column {
                    Text(
                        "IMAGE PUZZLE",
                        color = Color.White,
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Black
                    )
                    Text(
                        "LEVEL $currentLevel",
                        color = PuzzleGold,
                        fontSize = 12.sp,
                        letterSpacing = 1.5.sp,
                        fontWeight = FontWeight.ExtraBold
                    )
                }
                Spacer(Modifier.weight(1f))
                Surface(
                    modifier = Modifier.clickable(onClick = onChangeModel),
                    color = Color.White.copy(alpha = 0.20f),
                    shape = RoundedCornerShape(18.dp),
                    border = androidx.compose.foundation.BorderStroke(
                        1.dp,
                        Color.White.copy(alpha = 0.55f)
                    )
                ) {
                    Text(
                        "EDIT MODELS",
                        modifier = Modifier.padding(horizontal = 13.dp, vertical = 10.dp),
                        color = Color.White,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Black
                    )
                }
            }

            Spacer(Modifier.height(20.dp))
            Text(
                "READY TO PLAY?",
                color = PuzzleGold,
                fontSize = 13.sp,
                letterSpacing = 2.sp,
                fontWeight = FontWeight.Black
            )
            Text(
                "Put the beauty\nback together",
                color = Color.White,
                fontSize = 32.sp,
                lineHeight = 36.sp,
                fontWeight = FontWeight.Black,
                textAlign = TextAlign.Center
            )

            Spacer(Modifier.height(18.dp))
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .graphicsLayer {
                        scaleX = pulse
                        scaleY = pulse
                    }
                    .shadow(18.dp, RoundedCornerShape(28.dp)),
                color = Color.White.copy(alpha = 0.92f),
                shape = RoundedCornerShape(28.dp),
                border = androidx.compose.foundation.BorderStroke(2.dp, Color.White)
            ) {
                Column(
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 14.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                "YOUR MODEL COLLECTION",
                                color = PuzzleNavy,
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Black,
                                letterSpacing = 0.6.sp
                            )
                            Text(
                                "Every selected model can appear in your levels",
                                color = PuzzleNavy.copy(alpha = 0.58f),
                                fontSize = 10.sp
                            )
                        }
                        Spacer(Modifier.weight(1f))
                        Surface(color = PuzzleAqua, shape = CircleShape) {
                            Text(
                                "${actressIds.take(MAX_SELECTED_MODELS).size}/$MAX_SELECTED_MODELS",
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                                color = PuzzleNavy,
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Black
                            )
                        }
                    }

                    Spacer(Modifier.height(13.dp))
                    when {
                        loading -> Box(
                            modifier = Modifier.fillMaxWidth().height(145.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            CircularProgressIndicator(color = PuzzleTeal)
                        }
                        selectedModels.isEmpty() -> Box(
                            modifier = Modifier.fillMaxWidth().height(120.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                "Choose at least one model to begin",
                                color = PuzzleNavy,
                                fontWeight = FontWeight.Bold
                            )
                        }
                        else -> Column(
                            modifier = Modifier.fillMaxWidth(),
                            verticalArrangement = Arrangement.spacedBy(10.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            selectedModels.chunked(5).forEach { rowModels ->
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceEvenly
                                ) {
                                    rowModels.forEach { model ->
                                        SelectedModelAvatar(model)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Spacer(Modifier.height(12.dp))
            Text(
                "${selectedModels.size} models ready  •  Continue from Level $currentLevel",
                color = Color.White.copy(alpha = 0.88f),
                fontSize = 14.sp,
                fontWeight = FontWeight.SemiBold
            )
            Spacer(Modifier.weight(1f))
            PuzzlePrimaryButton(
                text = "START GAME  ▶",
                onClick = onStartGame,
                enabled = actressIds.isNotEmpty()
            )
            Spacer(Modifier.height(10.dp))
            Text(
                "Drag one tile onto another to swap their positions",
                color = Color.White.copy(alpha = 0.72f),
                fontSize = 12.sp
            )
        }
    }
}

@Composable
private fun SelectedModelAvatar(model: ActressData) {
    Column(
        modifier = Modifier.width(58.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(54.dp)
                .clip(CircleShape)
                .background(PuzzleAqua.copy(alpha = 0.55f))
                .border(2.5.dp, PuzzleGold, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            if (model.thumbnail_image != null) {
                AsyncImage(
                    model = "${ApiClient.BASE_SERVER_URL}uploads/actresses/thumbnails/${model.thumbnail_image}",
                    contentDescription = model.name,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize()
                )
            } else {
                Text(
                    model.name.take(1).uppercase(),
                    color = PuzzleNavy,
                    fontSize = 21.sp,
                    fontWeight = FontWeight.Black
                )
            }
        }
        Spacer(Modifier.height(4.dp))
        Text(
            model.name,
            color = PuzzleNavy,
            fontSize = 9.sp,
            lineHeight = 10.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}
