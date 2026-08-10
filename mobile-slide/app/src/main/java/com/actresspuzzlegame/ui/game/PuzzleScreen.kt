package com.actresspuzzlegame.ui.game

import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.key
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import coil.ImageLoader
import coil.request.ImageRequest
import coil.request.SuccessResult
import kotlin.math.abs

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
    var imageAspectRatio by remember(imageUrl) { mutableStateOf(4f / 5f) }
    var imageError by remember(imageUrl) { mutableStateOf<String?>(null) }
    var activeTileId by remember(imageUrl, rows, columns) { mutableStateOf<Int?>(null) }
    var dragStartPosition by remember(imageUrl, rows, columns) { mutableStateOf<Int?>(null) }
    var dragOffset by remember(imageUrl, rows, columns) { mutableStateOf(Offset.Zero) }
    val toneGenerator = remember { ToneGenerator(AudioManager.STREAM_MUSIC, 45) }
    val density = LocalDensity.current

    DisposableEffect(Unit) {
        onDispose { toneGenerator.release() }
    }

    LaunchedEffect(imageUrl, rows, columns, savedArrangement) {
        tileBitmaps = emptyList()
        imageError = null
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

        val source = bitmap.bitmap
        imageAspectRatio = source.width.toFloat() / source.height.toFloat()
        tileBitmaps = sliceBitmap(source, rows, columns)
    }

    LaunchedEffect(state.isCompleted) {
        if (state.isCompleted && tileBitmaps.isNotEmpty()) onCompleted()
    }

    when {
        imageError != null -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text(imageError.orEmpty(), color = MaterialTheme.colorScheme.error)
        }

        state.isLoading || tileBitmaps.size != rows * columns -> Box(
            Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator(color = Color.White)
        }

        else -> BoxWithConstraints(modifier = Modifier.fillMaxWidth()) {
            val boardWidth = maxWidth
            val boardHeight = boardWidth / imageAspectRatio
            val tileWidth = boardWidth / columns
            val tileHeight = boardHeight / rows
            val tileWidthPx = with(density) { tileWidth.toPx() }
            val tileHeightPx = with(density) { tileHeight.toPx() }

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(boardHeight)
                    .background(Color(0xFF172638))
                    .border(1.dp, Color(0xFF122033))
            ) {
                state.tiles.forEach { tile ->
                    key(tile.id) {
                        val isEmpty = tile.id == state.tiles.lastIndex && !state.isCompleted
                        val row = tile.currentPosition / columns
                        val column = tile.currentPosition % columns
                        val animatedX by animateDpAsState(
                            targetValue = tileWidth * column,
                            animationSpec = spring(
                                dampingRatio = Spring.DampingRatioNoBouncy,
                                stiffness = Spring.StiffnessMedium
                            ),
                            label = "tile_${tile.id}_x"
                        )
                        val animatedY by animateDpAsState(
                            targetValue = tileHeight * row,
                            animationSpec = spring(
                                dampingRatio = Spring.DampingRatioNoBouncy,
                                stiffness = Spring.StiffnessMedium
                            ),
                            label = "tile_${tile.id}_y"
                        )
                        val startPosition = dragStartPosition
                        val followsDrag = activeTileId != null && startPosition != null &&
                            positionIsInSlidePath(
                                position = tile.currentPosition,
                                startPosition = startPosition,
                                emptyPosition = state.emptyTilePosition,
                                columns = columns
                            )
                        val dragTranslationX by animateFloatAsState(
                            targetValue = if (followsDrag) dragOffset.x else 0f,
                            animationSpec = spring(
                                dampingRatio = Spring.DampingRatioNoBouncy,
                                stiffness = Spring.StiffnessHigh
                            ),
                            label = "tile_${tile.id}_drag_x"
                        )
                        val dragTranslationY by animateFloatAsState(
                            targetValue = if (followsDrag) dragOffset.y else 0f,
                            animationSpec = spring(
                                dampingRatio = Spring.DampingRatioNoBouncy,
                                stiffness = Spring.StiffnessHigh
                            ),
                            label = "tile_${tile.id}_drag_y"
                        )
                        val tileModifier = Modifier
                            .offset(x = animatedX, y = animatedY)
                            .graphicsLayer {
                                translationX = dragTranslationX
                                translationY = dragTranslationY
                                shadowElevation = if (tile.id == activeTileId) 12f else 0f
                            }
                            .zIndex(if (tile.id == activeTileId) 2f else if (followsDrag) 1f else 0f)
                            .size(width = tileWidth, height = tileHeight)
                            .border(0.6.dp, Color.White.copy(alpha = 0.9f))
                            .pointerInput(
                                tile.id,
                                tile.currentPosition,
                                state.emptyTilePosition,
                                state.canMove,
                                state.isCompleted
                            ) {
                                if (isEmpty || state.isCompleted || !state.canMove) return@pointerInput
                                detectDragGestures(
                                    onDragStart = {
                                        if (slideAxis(
                                                tile.currentPosition,
                                                state.emptyTilePosition,
                                                columns
                                            ) != null
                                        ) {
                                            activeTileId = tile.id
                                            dragStartPosition = tile.currentPosition
                                            dragOffset = Offset.Zero
                                        }
                                    },
                                    onDragCancel = {
                                        activeTileId = null
                                        dragStartPosition = null
                                        dragOffset = Offset.Zero
                                    },
                                    onDragEnd = {
                                        val position = dragStartPosition
                                        val axis = position?.let {
                                            slideAxis(it, state.emptyTilePosition, columns)
                                        }
                                        val distance = when (axis) {
                                            SlideAxis.Horizontal -> abs(dragOffset.x)
                                            SlideAxis.Vertical -> abs(dragOffset.y)
                                            null -> 0f
                                        }
                                        val cellSize = if (axis == SlideAxis.Horizontal) {
                                            tileWidthPx
                                        } else {
                                            tileHeightPx
                                        }
                                        val moved = position != null &&
                                            distance >= cellSize * DRAG_COMMIT_FRACTION &&
                                            viewModel.onTileSlid(position)

                                        activeTileId = null
                                        dragStartPosition = null
                                        dragOffset = Offset.Zero

                                        if (moved) {
                                            if (soundEnabled) {
                                                toneGenerator.startTone(
                                                    ToneGenerator.TONE_PROP_BEEP,
                                                    35
                                                )
                                            }
                                            if (vibrationEnabled) triggerVibration(context)
                                        }
                                    }
                                ) { change, dragAmount ->
                                    val position = dragStartPosition ?: return@detectDragGestures
                                    val axis = slideAxis(
                                        position,
                                        state.emptyTilePosition,
                                        columns
                                    ) ?: return@detectDragGestures
                                    val direction = slideDirection(
                                        position,
                                        state.emptyTilePosition
                                    )
                                    dragOffset = when (axis) {
                                        SlideAxis.Horizontal -> Offset(
                                            x = directionalDrag(
                                                dragOffset.x + dragAmount.x,
                                                direction,
                                                tileWidthPx
                                            ),
                                            y = 0f
                                        )
                                        SlideAxis.Vertical -> Offset(
                                            x = 0f,
                                            y = directionalDrag(
                                                dragOffset.y + dragAmount.y,
                                                direction,
                                                tileHeightPx
                                            )
                                        )
                                    }
                                    change.consume()
                                }
                            }

                        if (isEmpty) {
                            Box(tileModifier.background(Color(0xFF172638)))
                        } else {
                            Image(
                                bitmap = tileBitmaps[tile.bitmapRegion].asImageBitmap(),
                                contentDescription = "Puzzle tile ${tile.id + 1}",
                                contentScale = ContentScale.FillBounds,
                                modifier = tileModifier
                            )
                        }
                    }
                }
            }
        }
    }
}

private const val DRAG_COMMIT_FRACTION = 0.22f

private enum class SlideAxis { Horizontal, Vertical }

private fun slideAxis(tilePosition: Int, emptyPosition: Int, columns: Int): SlideAxis? = when {
    tilePosition == emptyPosition -> null
    tilePosition / columns == emptyPosition / columns &&
        abs(tilePosition - emptyPosition) == 1 -> SlideAxis.Horizontal
    tilePosition % columns == emptyPosition % columns &&
        abs(tilePosition - emptyPosition) == columns -> SlideAxis.Vertical
    else -> null
}

private fun slideDirection(tilePosition: Int, emptyPosition: Int): Float =
    if (tilePosition < emptyPosition) 1f else -1f

private fun directionalDrag(value: Float, direction: Float, maximum: Float): Float =
    (value * direction).coerceIn(0f, maximum) * direction

private fun positionIsInSlidePath(
    position: Int,
    startPosition: Int,
    emptyPosition: Int,
    columns: Int
): Boolean {
    return when (slideAxis(startPosition, emptyPosition, columns)) {
        SlideAxis.Horizontal -> position / columns == startPosition / columns &&
            position in minOf(startPosition, emptyPosition)..maxOf(startPosition, emptyPosition)
        SlideAxis.Vertical -> position % columns == startPosition % columns &&
            position in minOf(startPosition, emptyPosition)..maxOf(startPosition, emptyPosition)
        null -> false
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

private fun triggerVibration(context: android.content.Context) {
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
                VibrationEffect.createOneShot(35, VibrationEffect.DEFAULT_AMPLITUDE)
            )
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(35)
        }
    }
}
