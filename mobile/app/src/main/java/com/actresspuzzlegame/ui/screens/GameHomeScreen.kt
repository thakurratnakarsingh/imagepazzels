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
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
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
import com.actresspuzzlegame.ui.theme.PremiumAccent
import com.actresspuzzlegame.ui.theme.PremiumBackgroundDark
import com.actresspuzzlegame.ui.theme.PremiumGold
import com.actresspuzzlegame.ui.theme.PremiumGoldLight
import com.actresspuzzlegame.ui.theme.PremiumGradientAccent
import com.actresspuzzlegame.ui.theme.PremiumGradientGold
import com.actresspuzzlegame.ui.theme.PremiumPrimary
import com.actresspuzzlegame.ui.theme.PremiumStroke
import com.actresspuzzlegame.ui.theme.PremiumSurface
import com.actresspuzzlegame.ui.theme.PremiumSurfaceHighlight
import com.actresspuzzlegame.ui.theme.PremiumTextDark
import com.actresspuzzlegame.ui.theme.PremiumTextGray
import com.actresspuzzlegame.ui.theme.PremiumTextWhite
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
            actressIds.mapNotNull(modelsById::get)
        }.getOrDefault(emptyList())
        loading = false
    }

    val transition = rememberInfiniteTransition(label = "home_animation")
    val pulse by transition.animateFloat(
        initialValue = 0.985f,
        targetValue = 1.015f,
        animationSpec = infiniteRepeatable(animation = tween(1_800), repeatMode = RepeatMode.Reverse),
        label = "hero_pulse"
    )
    val bob by transition.animateFloat(
        initialValue = -7f,
        targetValue = 7f,
        animationSpec = infiniteRepeatable(animation = tween(2_100), repeatMode = RepeatMode.Reverse),
        label = "hero_bob"
    )
    val sparkle by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(animation = tween(4_800)),
        label = "home_sparkle"
    )

    PremiumGameBackground(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
    ) {
        HomeAmbientTiles(sparkle)

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 22.dp, vertical = 16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                PremiumLogo(titleSize = 21, subtitle = "Level $currentLevel")
                Spacer(Modifier.weight(1f))
                PremiumIconButton(
                    icon = GameIcon.User,
                    onClick = onChangeModel,
                    color = PremiumTextWhite,
                    contentDescription = "Change model selection"
                )
            }

            Spacer(Modifier.height(24.dp))
            Text(
                text = "READY TO PLAY?",
                color = PremiumGold,
                fontSize = 14.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = 1.2.sp
            )
            Text(
                text = "Put the picture\nback together",
                color = PremiumTextWhite,
                fontSize = 34.sp,
                lineHeight = 38.sp,
                fontWeight = FontWeight.Black,
                textAlign = TextAlign.Center
            )

            Spacer(Modifier.height(20.dp))
            HomeHeroShowcase(
                loading = loading,
                selectedModels = selectedModels,
                pulse = pulse,
                bob = bob
            )

            Spacer(Modifier.height(18.dp))
            ModelCollectionPanel(
                loading = loading,
                selectedModels = selectedModels,
                selectedCount = actressIds.size
            )

            Spacer(Modifier.height(14.dp))
            LevelJourneyPreview(currentLevel = currentLevel)

            Spacer(Modifier.weight(1f))
            PremiumGameButton(
                text = "PLAY",
                onClick = onStartGame,
                enabled = actressIds.isNotEmpty(),
                icon = GameIcon.Play,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(66.dp),
                primaryColor = PremiumGoldLight,
                secondaryColor = PremiumGold,
                textColor = PremiumTextDark
            )
        }
    }
}

@Composable
private fun HomeAmbientTiles(progress: Float) {
    Canvas(Modifier.fillMaxSize()) {
        repeat(10) { index ->
            val baseX = ((index * 71f) % size.width)
            val drift = sin((progress * Math.PI * 2.0 + index).toFloat()) * 8f
            val y = size.height * (0.12f + (index % 5) * 0.17f)
            val side = if (index % 3 == 0) 22f else 14f
            drawRoundRect(
                color = if (index % 2 == 0) PremiumAccent.copy(alpha = 0.12f) else PremiumGold.copy(alpha = 0.11f),
                topLeft = Offset(baseX + drift, y),
                size = Size(side, side),
                cornerRadius = CornerRadius(5f, 5f)
            )
        }
    }
}

@Composable
private fun HomeHeroShowcase(
    loading: Boolean,
    selectedModels: List<ActressData>,
    pulse: Float,
    bob: Float
) {
    val primaryModel = selectedModels.firstOrNull()
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
        Canvas(Modifier.fillMaxSize()) {
            repeat(8) { index ->
                val angle = Math.toRadians((index * 45).toDouble())
                val center = Offset(
                    x = size.width / 2f + cos(angle).toFloat() * size.width * 0.43f,
                    y = size.height / 2f + sin(angle).toFloat() * size.height * 0.38f
                )
                drawRoundRect(
                    color = if (index % 2 == 0) PremiumAccent.copy(alpha = 0.36f) else PremiumGold.copy(alpha = 0.30f),
                    topLeft = center - Offset(8f, 8f),
                    size = Size(16f, 16f),
                    cornerRadius = CornerRadius(4f, 4f)
                )
            }
        }
        Box(
            modifier = Modifier
                .size(218.dp)
                .shadow(26.dp, RoundedCornerShape(34.dp))
                .clip(RoundedCornerShape(34.dp))
                .background(PremiumSurface)
                .border(3.dp, PremiumStroke, RoundedCornerShape(34.dp)),
            contentAlignment = Alignment.Center
        ) {
            when {
                loading -> CircularProgressIndicator(color = PremiumAccent)
                primaryModel?.thumbnail_image != null -> AsyncImage(
                    model = "${ApiClient.BASE_SERVER_URL}uploads/actresses/thumbnails/${primaryModel.thumbnail_image}",
                    contentDescription = primaryModel.name,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize()
                )
                primaryModel != null -> Text(
                    text = primaryModel.name.take(1).uppercase(),
                    color = PremiumTextWhite,
                    fontSize = 76.sp,
                    fontWeight = FontWeight.Black
                )
                else -> GameIconCanvas(GameIcon.Puzzle, PremiumTextGray, Modifier.size(92.dp))
            }
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .background(
                        Brush.verticalGradient(
                            listOf(
                                Color.White.copy(alpha = 0.12f),
                                Color.Transparent,
                                PremiumBackgroundDark.copy(alpha = 0.28f)
                            )
                        )
                    )
            )
        }
    }
}

@Composable
private fun ModelCollectionPanel(
    loading: Boolean,
    selectedModels: List<ActressData>,
    selectedCount: Int
) {
    PremiumPanel(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp)
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 14.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(Modifier.weight(1f)) {
                    Text(
                        text = selectedModels.firstOrNull()?.name ?: "Your puzzle mix",
                        color = PremiumTextWhite,
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Black,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = if (selectedCount == 1) "1 model selected" else "$selectedCount models selected",
                        color = PremiumAccent,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(14.dp))
                        .background(Brush.horizontalGradient(PremiumGradientAccent))
                        .padding(horizontal = 12.dp, vertical = 7.dp)
                ) {
                    Text(
                        text = selectedCount.coerceAtLeast(0).toString(),
                        color = PremiumTextDark,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Black
                    )
                }
            }

            Spacer(Modifier.height(12.dp))
            when {
                loading -> Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(54.dp),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(
                        color = PremiumAccent,
                        strokeWidth = 3.dp,
                        modifier = Modifier.size(26.dp)
                    )
                }
                selectedModels.isEmpty() -> Text(
                    text = "Choose at least one model",
                    color = PremiumTextGray,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold
                )
                else -> Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    selectedModels.take(5).forEach { model ->
                        SelectedModelAvatar(model = model, modifier = Modifier.weight(1f))
                    }
                    val extra = selectedModels.size - 5
                    if (extra > 0) {
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .size(48.dp)
                                .clip(CircleShape)
                                .background(PremiumSurfaceHighlight),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "+$extra",
                                color = PremiumTextWhite,
                                fontWeight = FontWeight.Black
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun SelectedModelAvatar(model: ActressData, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(50.dp)
                .clip(CircleShape)
                .background(PremiumSurfaceHighlight)
                .border(2.dp, PremiumGold, CircleShape),
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
                    text = model.name.take(1).uppercase(),
                    color = PremiumTextWhite,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Black
                )
            }
        }
        Spacer(Modifier.height(5.dp))
        Text(
            text = model.name,
            color = PremiumTextGray,
            fontSize = 9.sp,
            lineHeight = 10.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

@Composable
private fun LevelJourneyPreview(currentLevel: Int) {
    val levels = remember(currentLevel) {
        listOf((currentLevel - 1).coerceAtLeast(1), currentLevel, currentLevel + 1).distinct()
    }
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        levels.forEach { level ->
            val isCurrent = level == currentLevel
            val isComplete = level < currentLevel
            LevelNode(
                level = level,
                label = when {
                    isComplete -> "DONE"
                    isCurrent -> "NOW"
                    else -> "NEXT"
                },
                enabled = level <= currentLevel,
                highlighted = isCurrent,
                modifier = Modifier.weight(1f)
            )
        }
    }
}

@Composable
private fun LevelNode(
    level: Int,
    label: String,
    enabled: Boolean,
    highlighted: Boolean,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .height(76.dp)
            .shadow(if (highlighted) 14.dp else 5.dp, RoundedCornerShape(18.dp))
            .clip(RoundedCornerShape(18.dp))
            .background(
                when {
                    highlighted -> Brush.verticalGradient(PremiumGradientGold)
                    enabled -> Brush.verticalGradient(listOf(PremiumSurfaceHighlight, PremiumSurface))
                    else -> Brush.verticalGradient(listOf(PremiumSurface.copy(alpha = 0.55f), PremiumSurface.copy(alpha = 0.38f)))
                }
            )
            .border(
                1.dp,
                if (highlighted) Color.White.copy(alpha = 0.55f) else PremiumStroke.copy(alpha = 0.55f),
                RoundedCornerShape(18.dp)
            )
            .padding(10.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = label,
                color = if (highlighted) PremiumTextDark else PremiumTextGray,
                fontSize = 9.sp,
                fontWeight = FontWeight.Black
            )
            Text(
                text = level.toString(),
                color = if (highlighted) PremiumTextDark else PremiumTextWhite,
                fontSize = 22.sp,
                fontWeight = FontWeight.Black
            )
            if (!enabled) {
                GameIconCanvas(GameIcon.Lock, PremiumTextGray, Modifier.size(12.dp))
            } else if (highlighted) {
                Box(
                    modifier = Modifier
                        .size(6.dp)
                        .clip(CircleShape)
                        .background(PremiumPrimary)
                )
            }
        }
    }
}
