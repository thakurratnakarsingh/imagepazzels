package com.actresspuzzlegame.ui.game

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class PuzzleViewModelTest {
    @Test
    fun restoredGameKeepsArrangementAndCounters() {
        val viewModel = PuzzleViewModel()
        val arrangement = listOf(0, 1, 2, 3, 4, 5, 6, 8, 7)

        viewModel.initializeGame(
            rows = 3,
            columns = 3,
            savedArrangement = arrangement,
            savedMoveCount = 12
        )

        assertEquals(arrangement, viewModel.tileArrangement())
        assertEquals(7, viewModel.state.value.emptyTilePosition)
        assertEquals(12, viewModel.state.value.moveCount)
        assertFalse(viewModel.state.value.isCompleted)
    }

    @Test
    fun onlyAdjacentTilesCanMove() {
        val viewModel = PuzzleViewModel()
        viewModel.initializeGame(
            rows = 3,
            columns = 3,
            savedArrangement = listOf(0, 1, 2, 3, 4, 5, 6, 8, 7)
        )

        assertFalse(viewModel.onTileClicked(0))
        assertEquals(0, viewModel.state.value.moveCount)

        assertTrue(viewModel.onTileClicked(8))
        assertEquals(1, viewModel.state.value.moveCount)
        assertTrue(viewModel.state.value.isCompleted)
    }

    @Test
    fun generatedPuzzleIsValidSolvableAndNotAlreadyComplete() {
        val viewModel = PuzzleViewModel()
        viewModel.initializeGame(rows = 5, columns = 5, shuffleMoves = 100)
        val arrangement = viewModel.tileArrangement()

        assertEquals((0 until 25).toSet(), arrangement.toSet())
        assertFalse(viewModel.state.value.isCompleted)
        assertTrue(isSolvable(arrangement, rows = 5, columns = 5))
    }

    private fun isSolvable(arrangement: List<Int>, rows: Int, columns: Int): Boolean {
        val blank = rows * columns - 1
        val tiles = arrangement.filter { it != blank }
        var inversions = 0
        for (left in tiles.indices) {
            for (right in left + 1 until tiles.size) {
                if (tiles[left] > tiles[right]) inversions++
            }
        }
        if (columns % 2 == 1) return inversions % 2 == 0
        val blankRowFromBottom = rows - arrangement.indexOf(blank) / columns
        return (blankRowFromBottom % 2 == 0) != (inversions % 2 == 0)
    }
}
