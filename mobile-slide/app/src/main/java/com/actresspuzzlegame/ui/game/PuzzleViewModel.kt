package com.actresspuzzlegame.ui.game

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class PuzzleViewModel : ViewModel() {
    private val _state = MutableStateFlow(PuzzleGameState())
    val state: StateFlow<PuzzleGameState> = _state.asStateFlow()

    fun initializeGame(
        rows: Int,
        columns: Int,
        shuffleMoves: Int = rows * columns * 8,
        savedArrangement: List<Int>? = null,
        savedMoveCount: Int = 0
    ) {
        require(rows >= 2 && columns >= 2) { "Puzzle must be at least 2 x 2" }
        val totalTiles = rows * columns
        val restoredIds = savedArrangement
            ?.takeIf { arrangement ->
                arrangement.size == totalTiles &&
                    arrangement.toSet() == (0 until totalTiles).toSet()
            }

        val tileIds = restoredIds ?: createSwapShuffle(
            totalTiles = totalTiles,
            moves = shuffleMoves.coerceAtLeast(totalTiles * 2)
        )
        val backendAnchorPosition = tileIds.indexOf(totalTiles - 1)
        val tiles = tileIds.mapIndexed { position, id ->
            Tile(id = id, currentPosition = position, bitmapRegion = id)
        }

        _state.value = PuzzleGameState(
            isLoading = false,
            tiles = tiles,
            rows = rows,
            columns = columns,
            // The API requires the position of tile N-1. It remains a visible tile
            // in swap mode and is used only as a progress-format anchor.
            emptyTilePosition = backendAnchorPosition,
            moveCount = savedMoveCount.coerceAtLeast(0),
            isCompleted = checkWinCondition(tiles)
        )
    }

    /**
     * Drops one visible tile onto another visible tile and exchanges their positions.
     * Any two different board positions are valid targets.
     */
    fun onTileDropped(sourcePosition: Int, targetPosition: Int): Boolean {
        val currentState = _state.value
        if (currentState.isCompleted || !currentState.canMove) return false
        if (sourcePosition !in currentState.tiles.indices) return false
        if (targetPosition !in currentState.tiles.indices) return false
        if (sourcePosition == targetPosition) return false

        val newTiles = currentState.tiles.toMutableList()
        val sourceTile = currentState.tiles[sourcePosition]
        val targetTile = currentState.tiles[targetPosition]
        newTiles[targetPosition] = sourceTile.copy(currentPosition = targetPosition)
        newTiles[sourcePosition] = targetTile.copy(currentPosition = sourcePosition)

        val isComplete = checkWinCondition(newTiles)
        _state.update {
            it.copy(
                tiles = newTiles,
                emptyTilePosition = newTiles.indexOfFirst { tile ->
                    tile.id == newTiles.lastIndex
                },
                moveCount = currentState.moveCount + 1,
                isCompleted = isComplete
            )
        }
        return true
    }

    fun setInteractionEnabled(enabled: Boolean) {
        _state.update { it.copy(canMove = enabled) }
    }

    fun tileArrangement(): List<Int> = _state.value.tiles.map { it.id }

    private fun checkWinCondition(tiles: List<Tile>): Boolean {
        // Win condition: every tile's ID matches its currentPosition
        return tiles.all { it.id == it.currentPosition }
    }

    private fun createSwapShuffle(totalTiles: Int, moves: Int): List<Int> {
        val arrangement = (0 until totalTiles).toMutableList()
        repeat(moves) {
            val first = arrangement.indices.random()
            var second = arrangement.indices.random()
            while (second == first) second = arrangement.indices.random()
            val firstTile = arrangement[first]
            arrangement[first] = arrangement[second]
            arrangement[second] = firstTile
        }

        if (arrangement.withIndex().all { (index, id) -> index == id }) {
            val firstTile = arrangement[0]
            arrangement[0] = arrangement[1]
            arrangement[1] = firstTile
        }

        return arrangement
    }
}
