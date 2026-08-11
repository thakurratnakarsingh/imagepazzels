package com.actresspuzzlegame.ui.screens

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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
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
fun ActressSelectionScreen(
    initialSelectedIds: Set<Int> = emptySet(),
    onSelectionConfirmed: (List<Int>) -> Unit
) {
    var actresses by remember { mutableStateOf<List<ActressData>>(emptyList()) }
    var selectedActressIds by remember(initialSelectedIds) {
        mutableStateOf(initialSelectedIds.take(MAX_SELECTED_MODELS).toSet())
    }
    var isLoading by remember { mutableStateOf(true) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var limitMessage by remember { mutableStateOf<String?>(null) }

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

    PuzzleBackground(Modifier.statusBarsPadding()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 18.dp)
        ) {
            Spacer(Modifier.height(14.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(52.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .border(1.5.dp, Color.White.copy(alpha = 0.6f), RoundedCornerShape(16.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Text("▦", color = PuzzleAqua, fontSize = 28.sp, fontWeight = FontWeight.Black)
                }
                Spacer(Modifier.width(12.dp))
                Column {
                    Text(
                        "CHOOSE YOUR MODELS",
                        color = Color.White,
                        fontSize = 23.sp,
                        fontWeight = FontWeight.Black
                    )
                    Text(
                        "Build your puzzle collection",
                        color = Color.White.copy(alpha = 0.76f),
                        fontSize = 13.sp
                    )
                }
                Spacer(Modifier.weight(1f))
                Surface(
                    color = if (selectedActressIds.size == MAX_SELECTED_MODELS) PuzzleGold else PuzzleAqua,
                    shape = RoundedCornerShape(18.dp)
                ) {
                    Text(
                        "${selectedActressIds.size}/$MAX_SELECTED_MODELS",
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                        color = PuzzleNavy,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Black
                    )
                }
            }

            Text(
                text = limitMessage ?: "Select up to 10 models. Tap again to remove a selection.",
                modifier = Modifier.fillMaxWidth().padding(top = 14.dp, bottom = 10.dp),
                color = if (limitMessage == null) Color.White.copy(alpha = 0.84f) else PuzzleGold,
                textAlign = TextAlign.Center,
                fontSize = 13.sp,
                fontWeight = if (limitMessage == null) FontWeight.Medium else FontWeight.Bold
            )

            Box(modifier = Modifier.weight(1f).fillMaxWidth()) {
                when {
                    isLoading -> CircularProgressIndicator(
                        modifier = Modifier.align(Alignment.Center),
                        color = PuzzleAqua
                    )
                    errorMessage != null -> Text(
                        text = errorMessage.orEmpty(),
                        modifier = Modifier.align(Alignment.Center).padding(24.dp),
                        color = Color.White,
                        textAlign = TextAlign.Center,
                        fontSize = 16.sp
                    )
                    actresses.isEmpty() -> Text(
                        "No models are available yet",
                        modifier = Modifier.align(Alignment.Center),
                        color = Color.White,
                        fontSize = 17.sp
                    )
                    else -> LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(vertical = 4.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        items(actresses, key = { it.id }) { actress ->
                            val isSelected = actress.id in selectedActressIds
                            val selectionLocked = !isSelected &&
                                selectedActressIds.size >= MAX_SELECTED_MODELS
                            Surface(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .shadow(8.dp, RoundedCornerShape(20.dp))
                                    .border(
                                        width = if (isSelected) 2.5.dp else 1.dp,
                                        color = if (isSelected) PuzzleGold else Color.White.copy(alpha = 0.4f),
                                        shape = RoundedCornerShape(20.dp)
                                    )
                                    .clickable {
                                        val update = toggleModelSelection(
                                            selectedActressIds,
                                            actress.id
                                        )
                                        selectedActressIds = update.selectedIds
                                        limitMessage = if (update.limitReached) {
                                            "You can select a maximum of 10 models"
                                        } else {
                                            null
                                        }
                                    },
                                color = when {
                                    isSelected -> Color(0xFFF2FCFF)
                                    selectionLocked -> Color.White.copy(alpha = 0.72f)
                                    else -> Color.White.copy(alpha = 0.92f)
                                },
                                shape = RoundedCornerShape(20.dp)
                            ) {
                                Row(
                                    modifier = Modifier.padding(11.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Box {
                                        AsyncImage(
                                            model = actress.thumbnail_image?.let {
                                                "${ApiClient.BASE_SERVER_URL}uploads/actresses/thumbnails/$it"
                                            },
                                            contentDescription = actress.name,
                                            modifier = Modifier
                                                .size(62.dp)
                                                .clip(CircleShape)
                                                .border(
                                                    3.dp,
                                                    if (isSelected) PuzzleGold else PuzzleAqua,
                                                    CircleShape
                                                ),
                                            contentScale = ContentScale.Crop
                                        )
                                        if (isSelected) {
                                            Box(
                                                modifier = Modifier
                                                    .align(Alignment.BottomEnd)
                                                    .size(23.dp)
                                                    .clip(CircleShape)
                                                    .border(2.dp, Color.White, CircleShape),
                                                contentAlignment = Alignment.Center
                                            ) {
                                                Surface(color = PuzzleTeal, shape = CircleShape) {
                                                    Text(
                                                        "✓",
                                                        modifier = Modifier.padding(horizontal = 4.dp),
                                                        color = Color.White,
                                                        fontSize = 13.sp,
                                                        fontWeight = FontWeight.Black
                                                    )
                                                }
                                            }
                                        }
                                    }
                                    Spacer(Modifier.width(14.dp))
                                    Column(Modifier.weight(1f)) {
                                        Text(
                                            actress.name,
                                            color = PuzzleNavy,
                                            fontSize = 18.sp,
                                            fontWeight = FontWeight.ExtraBold
                                        )
                                        Text(
                                            when {
                                                isSelected -> "Added to your game"
                                                selectionLocked -> "10-model limit reached"
                                                else -> "Tap to select"
                                            },
                                            color = if (isSelected) PuzzleTeal else PuzzleNavy.copy(alpha = 0.58f),
                                            fontSize = 12.sp
                                        )
                                    }
                                    Text(
                                        if (isSelected) "SELECTED" else "+",
                                        color = if (isSelected) PuzzleTeal else PuzzleNavy,
                                        fontSize = if (isSelected) 11.sp else 28.sp,
                                        fontWeight = FontWeight.Black
                                    )
                                }
                            }
                        }
                    }
                }
            }

            PuzzlePrimaryButton(
                text = "CONTINUE WITH ${selectedActressIds.size}  ▶",
                onClick = {
                    onSelectionConfirmed(selectedActressIds.take(MAX_SELECTED_MODELS))
                },
                enabled = selectedActressIds.isNotEmpty(),
                modifier = Modifier.padding(top = 12.dp, bottom = 18.dp)
            )
        }
    }
}
