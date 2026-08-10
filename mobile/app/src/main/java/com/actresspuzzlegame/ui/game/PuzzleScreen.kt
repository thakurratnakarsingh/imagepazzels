package com.actresspuzzlegame.ui.game

import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import coil.ImageLoader
import coil.request.ImageRequest
import coil.request.SuccessResult
import kotlinx.coroutines.launch

@Composable
fun PuzzleScreen(
    viewModel: PuzzleViewModel,
    imageUrl: String
) {
    val state by viewModel.state.collectAsState()
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()
    
    var originalBitmap by remember { mutableStateOf<Bitmap?>(null) }
    var tileBitmaps by remember { mutableStateOf<List<Bitmap>>(emptyList()) }

    // Load Image and slice it
    LaunchedEffect(imageUrl) {
        val loader = ImageLoader(context)
        val request = ImageRequest.Builder(context)
            .data(imageUrl)
            .allowHardware(false) // Software bitmap to allow cropping
            .build()
            
        val result = loader.execute(request)
        if (result is SuccessResult) {
            val drawable = result.drawable
            if (drawable is BitmapDrawable) {
                val bmp = drawable.bitmap
                originalBitmap = bmp
                
                // Chunk the bitmap
                val chunkWidth = bmp.width / state.columns
                val chunkHeight = bmp.height / state.rows
                val chunks = mutableListOf<Bitmap>()
                
                for (y in 0 until state.rows) {
                    for (x in 0 until state.columns) {
                        chunks.add(
                            Bitmap.createBitmap(bmp, x * chunkWidth, y * chunkHeight, chunkWidth, chunkHeight)
                        )
                    }
                }
                tileBitmaps = chunks
            }
        }
    }

    fun triggerVibration() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = context.getSystemService(VibratorManager::class.java)
            val vibrator = vibratorManager.defaultVibrator
            vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK))
        } else {
            @Suppress("DEPRECATION")
            val vibrator = context.getSystemService(Vibrator::class.java)
            vibrator?.vibrate(VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE))
        }
    }

    if (state.isLoading || tileBitmaps.isEmpty()) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("Loading Game...")
        }
    } else {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text("Moves: ${state.moveCount}")
            Spacer(modifier = Modifier.height(16.dp))
            
            if (state.isCompleted) {
                Text("Level Completed!")
                Spacer(modifier = Modifier.height(16.dp))
            }

            BoxWithConstraints(modifier = Modifier.fillMaxWidth().padding(16.dp)) {
                val gridWidth = maxWidth
                val tileWidth = gridWidth / state.columns
                val tileHeight = tileWidth * (tileBitmaps[0].height.toFloat() / tileBitmaps[0].width.toFloat())

                Box(modifier = Modifier.width(gridWidth).height(tileHeight * state.rows)) {
                    state.tiles.forEach { tile ->
                        // Don't draw the empty tile piece, but if game is won, fill the missing piece
                        if (tile.id != state.tiles.size - 1 || state.isCompleted) {
                            val row = tile.currentPosition / state.columns
                            val col = tile.currentPosition % state.columns

                            Image(
                                bitmap = tileBitmaps[tile.bitmapRegion].asImageBitmap(),
                                contentDescription = "Tile ${tile.id}",
                                modifier = Modifier
                                    .offset(x = tileWidth * col, y = tileHeight * row)
                                    .size(width = tileWidth, height = tileHeight)
                                    .clickable {
                                        viewModel.onTileClicked(tile.currentPosition)
                                        triggerVibration()
                                    }
                            )
                        }
                    }
                }
            }
        }
    }
}
