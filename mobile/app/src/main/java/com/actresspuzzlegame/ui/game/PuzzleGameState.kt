package com.actresspuzzlegame.ui.game

data class Tile(
    val id: Int, // The original correct index of the tile (0 to rows*cols-1)
    val currentPosition: Int, // Current index in the grid
    val bitmapRegion: Int // Index/ID for cropped bitmap logic
)

data class PuzzleGameState(
    val isLoading: Boolean = true,
    val tiles: List<Tile> = emptyList(),
    val rows: Int = 3,
    val columns: Int = 3,
    val emptyTilePosition: Int = 8,
    val moveCount: Int = 0,
    val isCompleted: Boolean = false
)
