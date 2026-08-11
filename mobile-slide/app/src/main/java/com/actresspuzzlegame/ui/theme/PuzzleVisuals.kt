package com.actresspuzzlegame.ui.theme

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun PuzzleBackground(
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    listOf(PuzzleSky, PuzzleBlue, Color(0xFF7895BF))
                )
            )
    ) {
        Canvas(Modifier.fillMaxSize()) {
            drawCircle(
                color = Color.White.copy(alpha = 0.08f),
                radius = size.minDimension * 0.48f,
                center = Offset(0f, size.height * 0.24f)
            )
            drawCircle(
                color = PuzzleAqua.copy(alpha = 0.10f),
                radius = size.minDimension * 0.42f,
                center = Offset(size.width, size.height * 0.72f)
            )
            repeat(14) { index ->
                val x = ((index * 83f) % size.width)
                val y = ((index * 137f + 80f) % size.height)
                drawCircle(
                    color = if (index % 3 == 0) {
                        PuzzleGold.copy(alpha = 0.42f)
                    } else {
                        Color.White.copy(alpha = 0.30f)
                    },
                    radius = if (index % 4 == 0) 5f else 2.8f,
                    center = Offset(x, y)
                )
            }
        }
        content()
    }
}

@Composable
fun PuzzlePrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(62.dp)
            .alpha(if (enabled) 1f else 0.55f)
            .shadow(14.dp, RoundedCornerShape(20.dp))
            .clip(RoundedCornerShape(20.dp))
            .background(
                Brush.horizontalGradient(listOf(PuzzleGold, PuzzleOrange))
            )
            .clickable(enabled = enabled && !loading, onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        if (loading) {
            CircularProgressIndicator(
                modifier = Modifier.height(28.dp),
                color = PuzzleNavy,
                strokeWidth = 3.dp
            )
        } else {
            Text(
                text = text,
                color = PuzzleNavy,
                fontSize = 19.sp,
                fontWeight = FontWeight.Black
            )
        }
    }
}
