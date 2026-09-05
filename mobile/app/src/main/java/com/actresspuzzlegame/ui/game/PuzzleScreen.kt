package com.actresspuzzlegame.ui.game

import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
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
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import coil.ImageLoader
import coil.request.ImageRequest
import coil.request.SuccessResult
import com.actresspuzzlegame.ui.theme.PremiumAccent
import com.actresspuzzlegame.ui.theme.PremiumBackgroundDark
import com.actresspuzzlegame.ui.theme.PremiumGold
import com.actresspuzzlegame.ui.theme.PremiumPrimaryLight
import com.actresspuzzlegame.ui.theme.PremiumStroke
import com.actresspuzzlegame.ui.theme.PremiumSuccess
import com.actresspuzzlegame.ui.theme.PremiumSurface
import com.actresspuzzlegame.ui.theme.PremiumSurfaceHighlight
import com.actresspuzzlegame.ui.theme.PremiumTextGray
import com.actresspuzzlegame.ui.theme.PremiumWarning
import kotlin.math.abs
import kotlin.math.roundToInt

@Composable
fun PuzzleScreen(
    viewModel: PuzzleViewModel,
    imageUrl: String,
    rows: Int,
    columns: Int,
    shuffleMoves: Int,
    savedArrangement: List<Int>? = null,
    savedMoveCount: Int = 0,
    soundEnabled: Boolean,
    vibrationEnabled: Boolean,
    onCompleted: () -> Unit
) {
    val state by viewModel.state.collectAsState()
    val context = LocalContext.current
    var tileBitmaps by remember(imageUrl, rows, columns) {
        mutableStateOf<List<Bitmap>>(emptyList())
    }
    var imageError by remember(imageUrl) { mutableStateOf<String?>(null) }
    var lastMovedTileId by remember(imageUrl, rows, columns) { mutableStateOf<Int?>(null) }
    var invalidTileId by remember(imageUrl, rows, columns) { mutableStateOf<Int?>(null) }
    val toneGenerator = remember { ToneGenerator(AudioManager.STREAM_MUSIC, 45) }

    DisposableEffect(Unit) {
        onDispose { toneGenerator.release() }
    }

    LaunchedEffect(imageUrl, rows, columns, savedArrangement) {
        tileBitmaps = emptyList()
        imageError = null
        lastMovedTileId = null
        invalidTileId = null
        viewModel.initializeGame(
            rows = rows,
            columns = columns,
            shuffleMoves = shuffleMoves,
            savedArrangement = savedArrangement,
            savedMoveCount = savedMoveCount
        )

        val request = ImageRequest.Builder(context)
            .data(imageUrl)
            .allowHardware(false)
            .build()

        val result = ImageLoader(context).execute(request)
        val bitmap = (result as? SuccessResult)?.drawable as? BitmapDrawable
        if (bitmap == null) {
            imageError = "Could not load this puzzle image"
            return@LaunchedEffect
        }

        val source = centerCropToAspectRatio(bitmap.bitmap, PUZZLE_BOARD_ASPECT_RATIO)
        tileBitmaps = sliceBitmap(source, rows, columns)
    }

    LaunchedEffect(state.isCompleted) {
        if (state.isCompleted && tileBitmaps.isNotEmpty()) {
            if (soundEnabled) toneGenerator.startTone(ToneGenerator.TONE_PROP_ACK, 120)
            onCompleted()
        }
    }

    fun signalInvalid(tileId: Int) {
        invalidTileId = tileId
        if (soundEnabled) toneGenerator.startTone(ToneGenerator.TONE_PROP_NACK, 55)
        if (vibrationEnabled) triggerVibration(context, 22)
    }

    fun moveTile(position: Int, tileId: Int): Boolean {
        val moved = viewModel.onTileClicked(position)
        if (moved) {
            lastMovedTileId = tileId
            if (soundEnabled) toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP, 35)
            if (vibrationEnabled) triggerVibration(context, 35)
        }
        return moved
    }

    when {
        imageError != null -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text(imageError.orEmpty(), color = PremiumWarning)
        }

        state.isLoading || tileBitmaps.size != rows * columns -> Box(
            Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator(color = PremiumPrimaryLight)
        }

        else -> PuzzleBoard(
            state = state,
            tileBitmaps = tileBitmaps,
            rows = rows,
            columns = columns,
            lastMovedTileId = lastMovedTileId,
            invalidTileId = invalidTileId,
            onInvalidAnimationDone = { tileId ->
                if (invalidTileId == tileId) invalidTileId = null
            },
            onMoveTile = ::moveTile,
            onInvalidTile = ::signalInvalid
        )
    }
}

@Composable
private fun PuzzleBoard(
    state: PuzzleGameState,
    tileBitmaps: List<Bitmap>,
    rows: Int,
    columns: Int,
    lastMovedTileId: Int?,
    invalidTileId: Int?,
    onInvalidAnimationDone: (Int) -> Unit,
    onMoveTile: (position: Int, tileId: Int) -> Boolean,
    onInvalidTile: (tileId: Int) -> Unit
) {
    val completionGlow by animateFloatAsState(
        targetValue = if (state.isCompleted) 1f else 0f,
        animationSpec = tween(520),
        label = "board_completion_glow"
    )

    BoxWithConstraints(modifier = Modifier.fillMaxWidth()) {
        val framePadding = 6.dp
        val innerWidth = (maxWidth - framePadding * 2).coerceAtLeast(1.dp)
        val innerHeight = innerWidth / PUZZLE_BOARD_ASPECT_RATIO
        val boardHeight = innerHeight + framePadding * 2
        val tileWidth = innerWidth / columns
        val tileHeight = innerHeight / rows

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(boardHeight)
                .shadow(
                    elevation = if (state.isCompleted) 28.dp else 18.dp,
                    shape = RoundedCornerShape(28.dp),
                    clip = false
                )
                .clip(RoundedCornerShape(28.dp))
                .background(
                    Brush.verticalGradient(
                        listOf(
                            PremiumSurfaceHighlight,
                            PremiumSurface,
                            PremiumBackgroundDark
                        )
                    )
                )
                .border(
                    width = if (state.isCompleted) 3.dp else 1.5.dp,
                    color = if (state.isCompleted) PremiumGold.copy(alpha = 0.95f) else PremiumStroke,
                    shape = RoundedCornerShape(28.dp)
                )
                .padding(framePadding)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .clip(RoundedCornerShape(22.dp))
                    .background(PremiumBackgroundDark.copy(alpha = 0.62f))
            ) {
                state.tiles.forEach { tile ->
                    key(tile.id) {
                        val isEmpty = tile.id == state.tiles.lastIndex && !state.isCompleted
                        val position = tile.currentPosition
                        val row = position / columns
                        val column = position % columns
                        val emptyRow = state.emptyTilePosition / columns
                        val emptyColumn = state.emptyTilePosition % columns
                        val rowDirection = emptyRow - row
                        val columnDirection = emptyColumn - column
                        val isAdjacent = abs(rowDirection) + abs(columnDirection) == 1
                        val isCorrect = tile.id == tile.currentPosition
                        var isPressed by remember { mutableStateOf(false) }
                        val shake = remember(tile.id) { Animatable(0f) }
                        val successPulse = remember(tile.id) { Animatable(0f) }

                        LaunchedEffect(invalidTileId) {
                            if (invalidTileId == tile.id) {
                                shake.snapTo(0f)
                                shake.animateTo(9f, tween(42))
                                shake.animateTo(-8f, tween(55))
                                shake.animateTo(5f, tween(45))
                                shake.animateTo(0f, tween(60))
                                onInvalidAnimationDone(tile.id)
                            }
                        }

                        LaunchedEffect(lastMovedTileId, isCorrect, state.isCompleted) {
                            if (lastMovedTileId == tile.id && (isCorrect || state.isCompleted)) {
                                successPulse.snapTo(0f)
                                successPulse.animateTo(1f, tween(130))
                                successPulse.animateTo(0f, tween(360))
                            }
                        }

                        val animatedX by animateDpAsState(
                            targetValue = tileWidth * column,
                            animationSpec = spring(
                                dampingRatio = Spring.DampingRatioMediumBouncy,
                                stiffness = Spring.StiffnessMedium
                            ),
                            label = "tile_x_${tile.id}"
                        )
                        val animatedY by animateDpAsState(
                            targetValue = tileHeight * row,
                            animationSpec = spring(
                                dampingRatio = Spring.DampingRatioMediumBouncy,
                                stiffness = Spring.StiffnessMedium
                            ),
                            label = "tile_y_${tile.id}"
                        )
                        val scale by animateFloatAsState(
                            targetValue = if (isPressed && !isEmpty && !state.isCompleted) 1.025f else 1f,
                            animationSpec = tween(95),
                            label = "tile_scale_${tile.id}"
                        )
                        val lift by animateDpAsState(
                            targetValue = when {
                                state.isCompleted || isEmpty -> 0.dp
                                isPressed -> 10.dp
                                isAdjacent -> 6.dp
                                else -> 3.dp
                            },
                            animationSpec = tween(130),
                            label = "tile_lift_${tile.id}"
                        )
                        val borderColor = when {
                            invalidTileId == tile.id -> PremiumWarning
                            state.isCompleted -> PremiumGold.copy(alpha = 0.35f)
                            isPressed -> PremiumGold
                            isAdjacent -> PremiumAccent.copy(alpha = 0.82f)
                            isCorrect -> PremiumSuccess.copy(alpha = 0.42f)
                            else -> Color.White.copy(alpha = 0.30f)
                        }

                        val tileModifier = Modifier
                            .offset(x = animatedX, y = animatedY)
                            .graphicsLayer { translationX = shake.value }
                            .zIndex(if (isPressed) 2f else 0f)
                            .size(width = tileWidth, height = tileHeight)
                            .padding(1.5.dp)
                            .scale(scale)
                            .shadow(lift, RoundedCornerShape(10.dp), clip = false)
                            .clip(RoundedCornerShape(10.dp))
                            .border(1.2.dp, borderColor, RoundedCornerShape(10.dp))
                            .pointerInput(position, state.emptyTilePosition, state.isCompleted, state.canMove) {
                                if (!state.isCompleted && state.canMove && isAdjacent && !isEmpty) {
                                    var totalDrag = Offset.Zero
                                    var movedDuringGesture = false
                                    val threshold = 24.dp.toPx()
                                    detectDragGestures(
                                        onDragStart = { isPressed = true },
                                        onDragEnd = { isPressed = false },
                                        onDragCancel = { isPressed = false },
                                        onDrag = { change, dragAmount ->
                                            change.consume()
                                            if (!movedDuringGesture) {
                                                totalDrag += dragAmount
                                                val movementTowardEmpty =
                                                    totalDrag.x * columnDirection + totalDrag.y * rowDirection
                                                if (movementTowardEmpty >= threshold) {
                                                    movedDuringGesture = onMoveTile(position, tile.id)
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                            .pointerInput(position, state.isCompleted, state.canMove, isAdjacent) {
                                if (!state.isCompleted && state.canMove && !isEmpty) {
                                    detectTapGestures(
                                        onPress = {
                                            isPressed = true
                                            val released = tryAwaitRelease()
                                            isPressed = false
                                            if (released) {
                                                if (isAdjacent) {
                                                    onMoveTile(position, tile.id)
                                                } else {
                                                    onInvalidTile(tile.id)
                                                }
                                            }
                                        }
                                    )
                                }
                            }

                        if (isEmpty) {
                            EmptyTile(tileModifier)
                        } else {
                            PictureTile(
                                bitmap = tileBitmaps[tile.bitmapRegion],
                                tileId = tile.id,
                                modifier = tileModifier,
                                isAdjacent = isAdjacent && !state.isCompleted,
                                isCorrect = isCorrect && !state.isCompleted,
                                successPulse = successPulse.value
                            )
                        }
                    }
                }

                if (completionGlow > 0f) {
                    Box(
                        modifier = Modifier
                            .matchParentSize()
                            .background(PremiumGold.copy(alpha = 0.10f * completionGlow))
                            .border(
                                3.dp,
                                PremiumGold.copy(alpha = 0.75f * completionGlow),
                                RoundedCornerShape(22.dp)
                            )
                    )
                }
            }
        }
    }
}

@Composable
private fun PictureTile(
    bitmap: Bitmap,
    tileId: Int,
    modifier: Modifier,
    isAdjacent: Boolean,
    isCorrect: Boolean,
    successPulse: Float
) {
    Box(modifier = modifier.background(PremiumSurface)) {
        Image(
            bitmap = bitmap.asImageBitmap(),
            contentDescription = "Puzzle tile ${tileId + 1}",
            contentScale = ContentScale.FillBounds,
            modifier = Modifier.matchParentSize()
        )
        Box(
            modifier = Modifier
                .matchParentSize()
                .background(
                    Brush.verticalGradient(
                        listOf(
                            Color.White.copy(alpha = 0.18f),
                            Color.Transparent,
                            Color.Black.copy(alpha = 0.10f)
                        )
                    )
                )
        )
        if (isCorrect) {
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .border(1.4.dp, PremiumSuccess.copy(alpha = 0.52f), RoundedCornerShape(10.dp))
            )
        }
        if (isAdjacent) {
            Canvas(Modifier.matchParentSize()) {
                drawRoundRect(
                    color = PremiumAccent.copy(alpha = 0.14f),
                    cornerRadius = CornerRadius(10.dp.toPx(), 10.dp.toPx())
                )
                drawCircle(
                    color = PremiumAccent.copy(alpha = 0.20f),
                    radius = size.minDimension * 0.20f,
                    center = Offset(size.width * 0.50f, size.height * 0.50f)
                )
            }
        }
        if (successPulse > 0f) {
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .background(PremiumSuccess.copy(alpha = 0.22f * successPulse))
            )
        }
    }
}

@Composable
private fun EmptyTile(modifier: Modifier) {
    Box(
        modifier = modifier.background(PremiumBackgroundDark.copy(alpha = 0.66f))
    ) {
        Canvas(Modifier.matchParentSize()) {
            drawRoundRect(
                color = PremiumSurfaceHighlight.copy(alpha = 0.42f),
                cornerRadius = CornerRadius(10.dp.toPx(), 10.dp.toPx()),
                style = Stroke(width = 2f)
            )
            val dot = size.minDimension * 0.08f
            repeat(2) { row ->
                repeat(2) { column ->
                    drawCircle(
                        color = PremiumTextGray.copy(alpha = 0.22f),
                        radius = dot,
                        center = Offset(
                            x = size.width * (0.38f + column * 0.24f),
                            y = size.height * (0.38f + row * 0.24f)
                        )
                    )
                }
            }
        }
    }
}

private const val PUZZLE_BOARD_ASPECT_RATIO = 0.70f

private fun centerCropToAspectRatio(source: Bitmap, targetAspectRatio: Float): Bitmap {
    val sourceAspectRatio = source.width.toFloat() / source.height.toFloat()
    if (abs(sourceAspectRatio - targetAspectRatio) < 0.001f) return source

    return if (sourceAspectRatio > targetAspectRatio) {
        val targetWidth = (source.height * targetAspectRatio).roundToInt()
            .coerceIn(1, source.width)
        val left = (source.width - targetWidth) / 2
        Bitmap.createBitmap(source, left, 0, targetWidth, source.height)
    } else {
        val targetHeight = (source.width / targetAspectRatio).roundToInt()
            .coerceIn(1, source.height)
        val top = (source.height - targetHeight) / 2
        Bitmap.createBitmap(source, 0, top, source.width, targetHeight)
    }
}

private fun sliceBitmap(source: Bitmap, rows: Int, columns: Int): List<Bitmap> {
    val chunks = ArrayList<Bitmap>(rows * columns)
    for (row in 0 until rows) {
        val top = row * source.height / rows
        val bottom = (row + 1) * source.height / rows
        for (column in 0 until columns) {
            val left = column * source.width / columns
            val right = (column + 1) * source.width / columns
            chunks += Bitmap.createBitmap(source, left, top, right - left, bottom - top)
        }
    }
    return chunks
}

private fun triggerVibration(context: android.content.Context, durationMs: Long) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val manager = context.getSystemService(VibratorManager::class.java)
        manager?.defaultVibrator?.vibrate(
            VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK)
        )
    } else {
        @Suppress("DEPRECATION")
        val vibrator = context.getSystemService(Vibrator::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(
                VibrationEffect.createOneShot(durationMs, VibrationEffect.DEFAULT_AMPLITUDE)
            )
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(durationMs)
        }
    }
}
