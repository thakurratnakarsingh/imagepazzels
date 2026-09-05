package com.actresspuzzlegame.ui.screens

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
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
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.actresspuzzlegame.network.ActressData
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.ui.theme.PremiumAccent
import com.actresspuzzlegame.ui.theme.PremiumAccentDark
import com.actresspuzzlegame.ui.theme.PremiumGold
import com.actresspuzzlegame.ui.theme.PremiumGoldLight
import com.actresspuzzlegame.ui.theme.PremiumGradientAccent
import com.actresspuzzlegame.ui.theme.PremiumPrimary
import com.actresspuzzlegame.ui.theme.PremiumPrimaryLight
import com.actresspuzzlegame.ui.theme.PremiumStroke
import com.actresspuzzlegame.ui.theme.PremiumSurface
import com.actresspuzzlegame.ui.theme.PremiumSurfaceHighlight
import com.actresspuzzlegame.ui.theme.PremiumTextDark
import com.actresspuzzlegame.ui.theme.PremiumTextGray
import com.actresspuzzlegame.ui.theme.PremiumTextWhite
import com.actresspuzzlegame.ui.theme.PremiumWarning

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
                errorMessage = "Models could not be loaded. Please try again."
            }
        } catch (_: Exception) {
            errorMessage = "Cannot reach the game server. Check your connection."
        } finally {
            isLoading = false
        }
    }

    PremiumGameBackground(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
    ) {
        Column(Modifier.fillMaxSize()) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    PremiumLogo(titleSize = 20, subtitle = "Choose your puzzle mix")
                }
                SelectedCountBadge(count = selectedActressIds.size)
            }

            Box(modifier = Modifier.fillMaxWidth().weight(1f)) {
                when {
                    isLoading -> CircularProgressIndicator(
                        color = PremiumPrimaryLight,
                        modifier = Modifier.align(Alignment.Center)
                    )
                    errorMessage != null -> PremiumPanel(
                        modifier = Modifier
                            .align(Alignment.Center)
                            .padding(24.dp),
                        shape = RoundedCornerShape(18.dp),
                        elevated = false
                    ) {
                        Text(
                            text = errorMessage.orEmpty(),
                            color = PremiumWarning,
                            textAlign = TextAlign.Center,
                            modifier = Modifier.padding(horizontal = 18.dp, vertical = 16.dp)
                        )
                    }
                    actresses.isEmpty() -> Text(
                        text = "No models are available yet",
                        color = PremiumTextGray,
                        modifier = Modifier.align(Alignment.Center)
                    )
                    else -> LazyColumn(
                        contentPadding = PaddingValues(horizontal = 18.dp, vertical = 8.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp),
                        modifier = Modifier.fillMaxSize()
                    ) {
                        items(actresses, key = { it.id }) { actress ->
                            val selected = actress.id in selectedActressIds
                            ActressSelectionCard(
                                actress = actress,
                                selected = selected,
                                onClick = {
                                    selectedActressIds = if (selected) {
                                        selectedActressIds - actress.id
                                    } else {
                                        selectedActressIds + actress.id
                                    }
                                }
                            )
                        }
                    }
                }
            }

            Box(modifier = Modifier.padding(horizontal = 18.dp, vertical = 14.dp)) {
                PremiumGameButton(
                    text = if (selectedActressIds.isEmpty()) {
                        "SELECT AT LEAST ONE"
                    } else {
                        "CONTINUE WITH ${selectedActressIds.size}"
                    },
                    onClick = { onSelectionConfirmed(selectedActressIds.toList()) },
                    enabled = selectedActressIds.isNotEmpty(),
                    icon = GameIcon.Check,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(62.dp)
                )
            }
        }
    }
}

@Composable
private fun SelectedCountBadge(count: Int) {
    Box(
        modifier = Modifier
            .shadow(8.dp, RoundedCornerShape(18.dp))
            .clip(RoundedCornerShape(18.dp))
            .background(Brush.horizontalGradient(PremiumGradientAccent))
            .border(1.dp, Color.White.copy(alpha = 0.34f), RoundedCornerShape(18.dp))
            .padding(horizontal = 13.dp, vertical = 9.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "$count selected",
            color = PremiumTextDark,
            fontSize = 13.sp,
            fontWeight = FontWeight.Black
        )
    }
}

@Composable
private fun ActressSelectionCard(
    actress: ActressData,
    selected: Boolean,
    onClick: () -> Unit
) {
    val scale by animateFloatAsState(
        targetValue = if (selected) 1.015f else 1f,
        animationSpec = tween(160),
        label = "model_card_scale"
    )
    val interactionSource = remember { MutableInteractionSource() }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .scale(scale)
            .shadow(if (selected) 15.dp else 7.dp, RoundedCornerShape(22.dp))
            .clip(RoundedCornerShape(22.dp))
            .background(
                if (selected) {
                    Brush.horizontalGradient(
                        listOf(
                            PremiumSurfaceHighlight,
                            PremiumSurface,
                            PremiumPrimary.copy(alpha = 0.45f)
                        )
                    )
                } else {
                    Brush.verticalGradient(listOf(PremiumSurfaceHighlight, PremiumSurface))
                }
            )
            .border(
                width = if (selected) 2.dp else 1.dp,
                color = if (selected) PremiumGold else PremiumStroke,
                shape = RoundedCornerShape(22.dp)
            )
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            )
    ) {
        Row(
            modifier = Modifier.padding(13.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(70.dp)
                    .shadow(8.dp, CircleShape)
                    .clip(CircleShape)
                    .background(PremiumSurface)
                    .border(3.dp, if (selected) PremiumGold else PremiumAccent, CircleShape),
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
                    Text(
                        text = actress.name.take(1).uppercase(),
                        color = PremiumTextWhite,
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Black
                    )
                }
            }
            Spacer(Modifier.width(15.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = actress.name,
                    color = PremiumTextWhite,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Black,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = if (selected) "In your puzzle mix" else "Available",
                    color = if (selected) PremiumGoldLight else PremiumTextGray,
                    fontSize = 12.sp,
                    fontWeight = if (selected) FontWeight.Bold else FontWeight.SemiBold
                )
            }
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(if (selected) PremiumGold else PremiumSurfaceHighlight)
                    .border(
                        1.dp,
                        if (selected) PremiumGoldLight else PremiumStroke,
                        CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (selected) {
                    GameIconCanvas(GameIcon.Check, PremiumTextDark, Modifier.size(18.dp))
                } else {
                    Box(
                        modifier = Modifier
                            .size(10.dp)
                            .clip(CircleShape)
                            .background(PremiumAccentDark)
                    )
                }
            }
        }
    }
}
