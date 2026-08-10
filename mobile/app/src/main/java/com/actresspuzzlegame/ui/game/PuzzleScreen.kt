package com.actresspuzzlegame.ui.game

import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import coil.ImageLoader
import coil.request.ImageRequest
import coil.request.SuccessResult

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
    val toneGenerator = remember { ToneGenerator(AudioManager.STREAM_MUSIC, 45) }

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

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(boardHeight)
                    .background(Color(0xFF172638))
                    .border(1.dp, Color(0xFF122033))
            ) {
                state.tiles.forEach { tile ->
                    val isEmpty = tile.id == state.tiles.lastIndex && !state.isCompleted
                    val row = tile.currentPosition / columns
                    val column = tile.currentPosition % columns
                    val tileModifier = Modifier
                        .offset(x = tileWidth * column, y = tileHeight * row)
                        .size(width = tileWidth, height = tileHeight)
                        .border(0.6.dp, Color.White.copy(alpha = 0.9f))
                        .clickable(enabled = !state.isCompleted) {
                            val moved = viewModel.onTileClicked(tile.currentPosition)
                            if (moved) {
                                if (soundEnabled) {
                                    toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP, 35)
                                }
                                if (vibrationEnabled) triggerVibration(context)
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
        vibrator?.vibrate(VibrationEffect.createOneShot(35, VibrationEffect.DEFAULT_AMPLITUDE))
    }
}
