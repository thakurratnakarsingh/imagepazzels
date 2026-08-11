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
    fun droppingTileOntoDistantTileSwapsThemAndCompletesPuzzle() {
        val viewModel = PuzzleViewModel()
        viewModel.initializeGame(
            rows = 3,
            columns = 3,
            savedArrangement = listOf(8, 1, 2, 3, 4, 5, 6, 7, 0)
        )

        assertTrue(viewModel.onTileDropped(sourcePosition = 0, targetPosition = 8))
        assertEquals((0 until 9).toList(), viewModel.tileArrangement())
        assertEquals(8, viewModel.state.value.emptyTilePosition)
        assertEquals(1, viewModel.state.value.moveCount)
        assertTrue(viewModel.state.value.isCompleted)
    }

    @Test
    fun displacedTileMovesBackToDraggedTilesOriginalPosition() {
        val viewModel = PuzzleViewModel()
        val arrangement = listOf(1, 2, 0, 3, 4, 5, 6, 7, 8)
        viewModel.initializeGame(
            rows = 3,
            columns = 3,
            savedArrangement = arrangement
        )

        assertTrue(viewModel.onTileDropped(sourcePosition = 0, targetPosition = 2))
        assertEquals(listOf(0, 2, 1, 3, 4, 5, 6, 7, 8), viewModel.tileArrangement())
        assertEquals(1, viewModel.state.value.moveCount)
    }

    @Test
    fun droppingBackOnSamePositionDoesNotCountAsMove() {
        val viewModel = PuzzleViewModel()
        val arrangement = listOf(1, 0, 2, 3, 4, 5, 6, 7, 8)
        viewModel.initializeGame(
            rows = 3,
            columns = 3,
            savedArrangement = arrangement
        )

        assertFalse(viewModel.onTileDropped(sourcePosition = 0, targetPosition = 0))
        assertEquals(arrangement, viewModel.tileArrangement())
        assertEquals(0, viewModel.state.value.moveCount)
    }

    @Test
    fun generatedSwapPuzzleContainsEveryVisibleTileAndIsNotComplete() {
        val viewModel = PuzzleViewModel()
        viewModel.initializeGame(rows = 5, columns = 5, shuffleMoves = 100)
        val arrangement = viewModel.tileArrangement()

        assertEquals((0 until 25).toSet(), arrangement.toSet())
        assertEquals(25, arrangement.size)
        assertFalse(viewModel.state.value.isCompleted)
    }
}
