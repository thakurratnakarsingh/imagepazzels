package com.actresspuzzlegame.ui.game

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class PuzzleViewModel : ViewModel() {
    private val _state = MutableStateFlow(PuzzleGameState())
    val state: StateFlow<PuzzleGameState> = _state.asStateFlow()

    fun initializeGame(rows: Int, columns: Int) {
        val totalTiles = rows * columns
        // Tile IDs: 0 to totalTiles-1. The last tile is empty (totalTiles-1)
        val initialTiles = List(totalTiles) { index ->
            Tile(id = index, currentPosition = index, bitmapRegion = index)
        }

        var shuffled = initialTiles
        var emptyPos = totalTiles - 1
        
        // Shuffle until we get a solvable permutation
        do {
            shuffled = shuffled.shuffled()
            emptyPos = shuffled.indexOfFirst { it.id == totalTiles - 1 }
        } while (!isSolvable(shuffled, rows, columns, emptyPos))

        // Update positions after shuffle
        shuffled = shuffled.mapIndexed { index, tile -> tile.copy(currentPosition = index) }

        _state.value = PuzzleGameState(
            isLoading = false,
            tiles = shuffled,
            rows = rows,
            columns = columns,
            emptyTilePosition = emptyPos,
            moveCount = 0
        )
    }

    fun onTileClicked(tilePosition: Int) {
        val currentState = _state.value
        if (currentState.isCompleted) return

        val emptyPos = currentState.emptyTilePosition
        val rows = currentState.rows
        val cols = currentState.columns

        // Check if adjacent (Manhattan distance)
        val clickedRow = tilePosition / cols
        val clickedCol = tilePosition % cols
        val emptyRow = emptyPos / cols
        val emptyCol = emptyPos % cols

        val isAdjacent = (Math.abs(clickedRow - emptyRow) + Math.abs(clickedCol - emptyCol)) == 1

        if (isAdjacent) {
            val newTiles = currentState.tiles.toMutableList()
            
            // Swap in list
            val clickedTile = newTiles[tilePosition]
            val emptyTile = newTiles[emptyPos]
            
            newTiles[tilePosition] = emptyTile.copy(currentPosition = tilePosition)
            newTiles[emptyPos] = clickedTile.copy(currentPosition = emptyPos)

            val newMoveCount = currentState.moveCount + 1
            val isComplete = checkWinCondition(newTiles)

            _state.update {
                it.copy(
                    tiles = newTiles,
                    emptyTilePosition = tilePosition,
                    moveCount = newMoveCount,
                    isCompleted = isComplete
                )
            }
        }
    }

    private fun checkWinCondition(tiles: List<Tile>): Boolean {
        // Win condition: every tile's ID matches its currentPosition
        return tiles.all { it.id == it.currentPosition }
    }

    private fun isSolvable(tiles: List<Tile>, rows: Int, cols: Int, emptyPos: Int): Boolean {
        var inversions = 0
        val tileIds = tiles.map { it.id }.filter { it != rows * cols - 1 }

        for (i in 0 until tileIds.size) {
            for (j in i + 1 until tileIds.size) {
                if (tileIds[i] > tileIds[j]) inversions++
            }
        }

        // For odd columns: solvable if inversions are even
        // For even columns: solvable if (inversions + blank_row_from_bottom) is odd (or even depending on formulation, blank row from bottom 1-indexed)
        if (cols % 2 != 0) {
            return inversions % 2 == 0
        } else {
            val emptyRowFromBottom = rows - (emptyPos / cols)
            return if (emptyRowFromBottom % 2 == 0) {
                inversions % 2 != 0
            } else {
                inversions % 2 == 0
            }
        }
    }
}
