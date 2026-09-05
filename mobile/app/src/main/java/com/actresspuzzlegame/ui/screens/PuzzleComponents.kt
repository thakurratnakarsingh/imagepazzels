package com.actresspuzzlegame.ui.screens

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.Canvas
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.actresspuzzlegame.ui.theme.*
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin

enum class GameIcon {
    Play,
    Settings,
    User,
    Save,
    Mail,
    Close,
    Home,
    Replay,
    Share,
    Puzzle,
    Check,
    Lock
}

@Composable
fun PremiumGameBackground(
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    Box(
        modifier = modifier
            .background(Brush.verticalGradient(PremiumGradientBg))
    ) {
        Canvas(Modifier.matchParentSize()) {
            val tile = size.minDimension * 0.13f
            val gap = tile * 0.38f
            repeat(7) { row ->
                repeat(4) { column ->
                    val x = -tile * 0.35f + column * (tile + gap) + if (row % 2 == 0) tile * 0.35f else 0f
                    val y = size.height * 0.08f + row * (tile + gap)
                    val alpha = if ((row + column) % 3 == 0) 0.085f else 0.045f
                    drawRoundRect(
                        color = Color.White.copy(alpha = alpha),
                        topLeft = Offset(x, y),
                        size = Size(tile, tile),
                        cornerRadius = CornerRadius(tile * 0.2f, tile * 0.2f),
                        style = Stroke(width = 2.5f)
                    )
                }
            }
            drawLine(
                color = PremiumAccent.copy(alpha = 0.14f),
                start = Offset(size.width * 0.08f, size.height * 0.18f),
                end = Offset(size.width * 0.92f, size.height * 0.10f),
                strokeWidth = 3f,
                cap = StrokeCap.Round
            )
            drawLine(
                color = PremiumGold.copy(alpha = 0.12f),
                start = Offset(size.width * 0.18f, size.height * 0.92f),
                end = Offset(size.width * 0.86f, size.height * 0.78f),
                strokeWidth = 4f,
                cap = StrokeCap.Round
            )
        }
        content()
    }
}

@Composable
fun PremiumLogo(
    modifier: Modifier = Modifier,
    titleSize: Int = 28,
    subtitle: String? = null
) {
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size((titleSize + 24).dp)
                .shadow(10.dp, RoundedCornerShape(16.dp))
                .clip(RoundedCornerShape(16.dp))
                .background(Brush.verticalGradient(PremiumGradientPrimary))
                .border(1.dp, Color.White.copy(alpha = 0.28f), RoundedCornerShape(16.dp)),
            contentAlignment = Alignment.Center
        ) {
            GameIconCanvas(GameIcon.Puzzle, PremiumTextWhite, Modifier.size((titleSize + 2).dp))
        }
        Spacer(Modifier.width(11.dp))
        Column {
            Text(
                text = "IMAGE PUZZLE",
                color = PremiumTextWhite,
                fontSize = titleSize.sp,
                fontWeight = FontWeight.Black,
                lineHeight = (titleSize + 2).sp
            )
            subtitle?.let {
                Text(
                    text = it,
                    color = PremiumTextGray,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }
    }
}

@Composable
fun PremiumGameButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false,
    icon: GameIcon? = null,
    primaryColor: Color = PremiumPrimary,
    secondaryColor: Color = PremiumPrimaryDark,
    textColor: Color = PremiumTextWhite
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed && enabled && !loading) 0.96f else 1f,
        animationSpec = tween(durationMillis = 90),
        label = "button_scale"
    )

    Box(
        modifier = modifier
            .scale(scale)
            .shadow(if (enabled && !isPressed) 8.dp else 2.dp, RoundedCornerShape(22.dp))
            .clip(RoundedCornerShape(22.dp))
            .background(
                if (enabled && !loading) {
                    Brush.verticalGradient(listOf(primaryColor, secondaryColor))
                } else {
                    Brush.verticalGradient(listOf(PremiumSurfaceHighlight, PremiumSurface))
                }
            )
            .border(
                1.5.dp,
                if (enabled) primaryColor.copy(alpha = 0.5f) else PremiumSurfaceHighlight,
                RoundedCornerShape(22.dp)
            )
            .clickable(
                enabled = enabled && !loading,
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            ),
        contentAlignment = Alignment.Center
    ) {
        if (loading) {
            CircularProgressIndicator(
                color = textColor,
                strokeWidth = 3.dp,
                modifier = Modifier.size(24.dp)
            )
        } else {
            Row(
                modifier = Modifier.padding(horizontal = 22.dp, vertical = 15.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                icon?.let {
                    GameIconCanvas(
                        icon = it,
                        color = if (enabled) textColor else PremiumTextGray,
                        modifier = Modifier.size(21.dp)
                    )
                    Spacer(Modifier.width(9.dp))
                }
                Text(
                    text = text,
                    color = if (enabled) textColor else PremiumTextGray,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.Black
                )
            }
        }
    }
}

@Composable
fun PremiumIconButton(
    icon: GameIcon,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    size: Dp = 54.dp,
    color: Color = PremiumAccent,
    enabled: Boolean = true,
    contentDescription: String? = null
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed && enabled) 0.92f else 1f,
        animationSpec = tween(durationMillis = 90),
        label = "icon_button_scale"
    )

    Box(
        modifier = modifier
            .scale(scale)
            .size(size)
            .shadow(if (!isPressed) 6.dp else 1.dp, CircleShape)
            .clip(CircleShape)
            .background(PremiumSurface.copy(alpha = if (enabled) 0.96f else 0.52f))
            .border(1.5.dp, PremiumSurfaceHighlight.copy(alpha = 0.86f), CircleShape)
            .then(
                if (contentDescription != null) {
                    Modifier.semantics { this.contentDescription = contentDescription }
                } else {
                    Modifier
                }
            )
            .clickable(
                enabled = enabled,
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            ),
        contentAlignment = Alignment.Center
    ) {
        GameIconCanvas(
            icon = icon,
            color = if (enabled) color else PremiumTextGray,
            modifier = Modifier.size(size * 0.46f)
        )
    }
}

@Composable
fun PremiumPanel(
    modifier: Modifier = Modifier,
    shape: Shape = RoundedCornerShape(24.dp),
    elevated: Boolean = true,
    content: @Composable () -> Unit
) {
    Box(
        modifier = modifier
            .shadow(if (elevated) 16.dp else 4.dp, shape)
            .clip(shape)
            .background(
                Brush.verticalGradient(
                    listOf(
                        PremiumSurfaceHighlight.copy(alpha = 0.44f),
                        PremiumSurface.copy(alpha = 0.92f)
                    )
                )
            )
            .border(1.dp, PremiumSurfaceHighlight.copy(alpha = 0.8f), shape)
            .padding(1.dp)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .clip(shape)
                .background(PremiumSurface.copy(alpha = 0.93f))
        ) {
            content()
        }
    }
}

@Composable
fun PremiumStatChip(
    label: String,
    value: String,
    modifier: Modifier = Modifier,
    accentColor: Color = PremiumAccent
) {
    PremiumPanel(
        modifier = modifier,
        shape = RoundedCornerShape(16.dp),
        elevated = false
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 14.dp, vertical = 9.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = label.uppercase(),
                color = PremiumTextGray,
                fontSize = 9.sp,
                fontWeight = FontWeight.Black
            )
            Text(
                text = value,
                color = accentColor,
                fontSize = 16.sp,
                fontWeight = FontWeight.Black
            )
        }
    }
}

@Composable
fun PremiumStars(
    stars: Int,
    modifier: Modifier = Modifier,
    starSize: Dp = 30.dp
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        repeat(3) { index ->
            val filled = index < stars.coerceIn(0, 3)
            Canvas(Modifier.size(starSize)) {
                val outer = size.minDimension * 0.48f
                val inner = outer * 0.46f
                val path = starPath(
                    center = Offset(size.width / 2f, size.height / 2f),
                    outerRadius = outer,
                    innerRadius = inner
                )
                if (filled) {
                    drawPath(path, PremiumGold)
                    drawPath(
                        path,
                        Color.White.copy(alpha = 0.38f),
                        style = Stroke(width = 2f, join = StrokeJoin.Round)
                    )
                } else {
                    drawPath(
                        path,
                        PremiumTextGray.copy(alpha = 0.52f),
                        style = Stroke(width = 2.4f, join = StrokeJoin.Round)
                    )
                }
            }
        }
    }
}

@Composable
fun GameIconCanvas(
    icon: GameIcon,
    color: Color,
    modifier: Modifier = Modifier.size(24.dp)
) {
    Canvas(modifier) {
        val stroke = Stroke(
            width = size.minDimension * 0.105f,
            cap = StrokeCap.Round,
            join = StrokeJoin.Round
        )
        when (icon) {
            GameIcon.Play -> {
                val path = Path().apply {
                    moveTo(size.width * 0.35f, size.height * 0.22f)
                    lineTo(size.width * 0.76f, size.height * 0.50f)
                    lineTo(size.width * 0.35f, size.height * 0.78f)
                    close()
                }
                drawPath(path, color)
            }

            GameIcon.Settings -> {
                drawCircle(color, radius = size.minDimension * 0.16f, center = center)
                repeat(8) { index ->
                    val angle = (PI * 2.0 * index / 8.0).toFloat()
                    val start = center + Offset(cos(angle), sin(angle)) * size.minDimension * 0.28f
                    val end = center + Offset(cos(angle), sin(angle)) * size.minDimension * 0.43f
                    drawLine(color, start, end, strokeWidth = stroke.width, cap = StrokeCap.Round)
                }
            }

            GameIcon.User -> {
                drawCircle(
                    color = color,
                    radius = size.minDimension * 0.16f,
                    center = Offset(size.width * 0.5f, size.height * 0.32f)
                )
                drawArc(
                    color = color,
                    startAngle = 205f,
                    sweepAngle = 130f,
                    useCenter = false,
                    topLeft = Offset(size.width * 0.19f, size.height * 0.43f),
                    size = Size(size.width * 0.62f, size.height * 0.56f),
                    style = stroke
                )
            }

            GameIcon.Save -> {
                drawRoundRect(
                    color = color,
                    topLeft = Offset(size.width * 0.18f, size.height * 0.16f),
                    size = Size(size.width * 0.64f, size.height * 0.68f),
                    cornerRadius = CornerRadius(size.minDimension * 0.08f, size.minDimension * 0.08f),
                    style = stroke
                )
                drawLine(
                    color,
                    Offset(size.width * 0.32f, size.height * 0.20f),
                    Offset(size.width * 0.68f, size.height * 0.20f),
                    strokeWidth = stroke.width,
                    cap = StrokeCap.Round
                )
                drawLine(
                    color,
                    Offset(size.width * 0.35f, size.height * 0.67f),
                    Offset(size.width * 0.65f, size.height * 0.67f),
                    strokeWidth = stroke.width,
                    cap = StrokeCap.Round
                )
            }

            GameIcon.Mail -> {
                drawRoundRect(
                    color = color,
                    topLeft = Offset(size.width * 0.13f, size.height * 0.24f),
                    size = Size(size.width * 0.74f, size.height * 0.54f),
                    cornerRadius = CornerRadius(size.minDimension * 0.08f, size.minDimension * 0.08f),
                    style = stroke
                )
                drawLine(color, Offset(size.width * 0.18f, size.height * 0.30f), center, stroke.width, StrokeCap.Round)
                drawLine(color, Offset(size.width * 0.82f, size.height * 0.30f), center, stroke.width, StrokeCap.Round)
            }

            GameIcon.Close -> {
                drawLine(color, Offset(size.width * 0.28f, size.height * 0.28f), Offset(size.width * 0.72f, size.height * 0.72f), stroke.width, StrokeCap.Round)
                drawLine(color, Offset(size.width * 0.72f, size.height * 0.28f), Offset(size.width * 0.28f, size.height * 0.72f), stroke.width, StrokeCap.Round)
            }

            GameIcon.Home -> {
                val roof = Path().apply {
                    moveTo(size.width * 0.18f, size.height * 0.48f)
                    lineTo(size.width * 0.50f, size.height * 0.20f)
                    lineTo(size.width * 0.82f, size.height * 0.48f)
                }
                drawPath(roof, color, style = stroke)
                drawRoundRect(
                    color = color,
                    topLeft = Offset(size.width * 0.28f, size.height * 0.46f),
                    size = Size(size.width * 0.44f, size.height * 0.36f),
                    cornerRadius = CornerRadius(size.minDimension * 0.06f, size.minDimension * 0.06f),
                    style = stroke
                )
            }

            GameIcon.Replay -> {
                drawArc(
                    color = color,
                    startAngle = 55f,
                    sweepAngle = 285f,
                    useCenter = false,
                    topLeft = Offset(size.width * 0.18f, size.height * 0.18f),
                    size = Size(size.width * 0.64f, size.height * 0.64f),
                    style = stroke
                )
                val path = Path().apply {
                    moveTo(size.width * 0.36f, size.height * 0.16f)
                    lineTo(size.width * 0.58f, size.height * 0.18f)
                    lineTo(size.width * 0.45f, size.height * 0.36f)
                    close()
                }
                drawPath(path, color)
            }

            GameIcon.Share -> {
                val points = listOf(
                    Offset(size.width * 0.28f, size.height * 0.56f),
                    Offset(size.width * 0.70f, size.height * 0.30f),
                    Offset(size.width * 0.72f, size.height * 0.76f)
                )
                drawLine(color, points[0], points[1], stroke.width, StrokeCap.Round)
                drawLine(color, points[0], points[2], stroke.width, StrokeCap.Round)
                points.forEach { drawCircle(color, size.minDimension * 0.10f, it) }
            }

            GameIcon.Puzzle -> {
                val gap = size.minDimension * 0.06f
                val cell = (size.minDimension - gap) / 2f
                repeat(2) { row ->
                    repeat(2) { column ->
                        drawRoundRect(
                            color = color,
                            topLeft = Offset(column * (cell + gap), row * (cell + gap)),
                            size = Size(cell, cell),
                            cornerRadius = CornerRadius(cell * 0.22f, cell * 0.22f)
                        )
                    }
                }
            }

            GameIcon.Check -> {
                drawLine(color, Offset(size.width * 0.20f, size.height * 0.54f), Offset(size.width * 0.42f, size.height * 0.74f), stroke.width, StrokeCap.Round)
                drawLine(color, Offset(size.width * 0.42f, size.height * 0.74f), Offset(size.width * 0.82f, size.height * 0.28f), stroke.width, StrokeCap.Round)
            }

            GameIcon.Lock -> {
                drawRoundRect(
                    color = color,
                    topLeft = Offset(size.width * 0.22f, size.height * 0.44f),
                    size = Size(size.width * 0.56f, size.height * 0.38f),
                    cornerRadius = CornerRadius(size.minDimension * 0.08f, size.minDimension * 0.08f),
                    style = stroke
                )
                drawArc(
                    color = color,
                    startAngle = 200f,
                    sweepAngle = 140f,
                    useCenter = false,
                    topLeft = Offset(size.width * 0.32f, size.height * 0.17f),
                    size = Size(size.width * 0.36f, size.height * 0.42f),
                    style = stroke
                )
            }
        }
    }
}

private fun starPath(center: Offset, outerRadius: Float, innerRadius: Float): Path {
    val path = Path()
    repeat(10) { index ->
        val radius = if (index % 2 == 0) outerRadius else innerRadius
        val angle = -PI / 2.0 + index * PI / 5.0
        val point = Offset(
            x = center.x + cos(angle).toFloat() * radius,
            y = center.y + sin(angle).toFloat() * radius
        )
        if (index == 0) path.moveTo(point.x, point.y) else path.lineTo(point.x, point.y)
    }
    path.close()
    return path
}
