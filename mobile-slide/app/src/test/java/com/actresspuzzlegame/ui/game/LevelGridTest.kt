package com.actresspuzzlegame.ui.game

import org.junit.Assert.assertEquals
import org.junit.Test

class LevelGridTest {
    @Test
    fun levelsOneThroughTwentyFiveUseNineTiles() {
        assertEquals(3, gridSizeForLevel(1))
        assertEquals(3, gridSizeForLevel(25))
    }

    @Test
    fun levelsTwentySixThroughFiftyUseSixteenTiles() {
        assertEquals(4, gridSizeForLevel(26))
        assertEquals(4, gridSizeForLevel(50))
    }

    @Test
    fun levelsFiftyOneThroughOneThousandUseTwentyFiveTiles() {
        assertEquals(5, gridSizeForLevel(51))
        assertEquals(5, gridSizeForLevel(1_000))
    }
}
