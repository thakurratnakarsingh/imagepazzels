package com.actresspuzzlegame.ui.game

data class Tile(
    val id: Int,
    val currentPosition: Int,
    val bitmapRegion: Int
)

data class PuzzleGameState(
    val isLoading: Boolean = true,
    val tiles: List<Tile> = emptyList(),
    val rows: Int = 3,
    val columns: Int = 3,
    // Position of tile N-1, retained because the shared API requires this field.
    // All tiles, including this one, remain visible and draggable in swap mode.
    val emptyTilePosition: Int = 8,
    val moveCount: Int = 0,
    val isCompleted: Boolean = false,
    val canMove: Boolean = true
)
