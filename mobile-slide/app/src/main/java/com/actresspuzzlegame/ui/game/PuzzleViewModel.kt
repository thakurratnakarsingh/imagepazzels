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

        val tileIds = restoredIds ?: createSolvableShuffle(
            rows = rows,
            columns = columns,
            moves = shuffleMoves.coerceAtLeast(totalTiles * 2)
        )
        val emptyPos = tileIds.indexOf(totalTiles - 1)
        val tiles = tileIds.mapIndexed { position, id ->
            Tile(id = id, currentPosition = position, bitmapRegion = id)
        }

        _state.value = PuzzleGameState(
            isLoading = false,
            tiles = tiles,
            rows = rows,
            columns = columns,
            emptyTilePosition = emptyPos,
            moveCount = savedMoveCount.coerceAtLeast(0),
            isCompleted = checkWinCondition(tiles)
        )
    }

    /**
     * Slides a tile into the adjacent empty cell. Keeping one adjacent swap per move
     * preserves the original client's saved arrangements, shuffle rules, and server
     * scoring while this client supplies the finger-driven interaction.
     */
    fun onTileSlid(tilePosition: Int): Boolean {
        val currentState = _state.value
        if (currentState.isCompleted || !currentState.canMove) return false
        if (tilePosition !in currentState.tiles.indices) return false

        val emptyPos = currentState.emptyTilePosition
        val cols = currentState.columns
        if (tilePosition == emptyPos) return false

        val tileRow = tilePosition / cols
        val tileColumn = tilePosition % cols
        val emptyRow = emptyPos / cols
        val emptyColumn = emptyPos % cols
        val isAdjacent = kotlin.math.abs(tileRow - emptyRow) +
            kotlin.math.abs(tileColumn - emptyColumn) == 1
        if (!isAdjacent) return false

        val newTiles = currentState.tiles.toMutableList()
        val emptyTile = currentState.tiles[emptyPos]
        val selectedTile = currentState.tiles[tilePosition]
        newTiles[emptyPos] = selectedTile.copy(currentPosition = emptyPos)
        newTiles[tilePosition] = emptyTile.copy(currentPosition = tilePosition)

        val isComplete = checkWinCondition(newTiles)
        _state.update {
            it.copy(
                tiles = newTiles,
                emptyTilePosition = tilePosition,
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

    private fun createSolvableShuffle(rows: Int, columns: Int, moves: Int): List<Int> {
        val total = rows * columns
        val arrangement = (0 until total).toMutableList()
        var emptyPosition = total - 1
        var previousEmptyPosition = -1

        repeat(moves) {
            val emptyRow = emptyPosition / columns
            val emptyColumn = emptyPosition % columns
            val candidates = buildList {
                if (emptyRow > 0) add(emptyPosition - columns)
                if (emptyRow < rows - 1) add(emptyPosition + columns)
                if (emptyColumn > 0) add(emptyPosition - 1)
                if (emptyColumn < columns - 1) add(emptyPosition + 1)
            }.filter { it != previousEmptyPosition }

            val nextPosition = (candidates.ifEmpty { listOf(previousEmptyPosition) }).random()
            arrangement[emptyPosition] = arrangement[nextPosition]
            arrangement[nextPosition] = total - 1
            previousEmptyPosition = emptyPosition
            emptyPosition = nextPosition
        }

        if (arrangement.withIndex().all { (index, id) -> index == id }) {
            val emptyRow = emptyPosition / columns
            val neighbor = if (emptyRow > 0) emptyPosition - columns else emptyPosition + columns
            arrangement[emptyPosition] = arrangement[neighbor]
            arrangement[neighbor] = total - 1
        }

        return arrangement
    }
}
