package com.actresspuzzlegame.ui.screens

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ModelSelectionPolicyTest {
    @Test
    fun eleventhModelIsRejected() {
        val selectedIds = (1..MAX_SELECTED_MODELS).toSet()

        val update = toggleModelSelection(selectedIds, modelId = 11)

        assertEquals(selectedIds, update.selectedIds)
        assertTrue(update.limitReached)
    }

    @Test
    fun selectedModelCanBeRemovedAfterLimitIsReached() {
        val update = toggleModelSelection((1..MAX_SELECTED_MODELS).toSet(), modelId = 4)

        assertEquals(9, update.selectedIds.size)
        assertFalse(4 in update.selectedIds)
        assertFalse(update.limitReached)
    }

    @Test
    fun modelCanBeAddedWhenSelectionIsBelowLimit() {
        val update = toggleModelSelection((1..9).toSet(), modelId = 10)

        assertEquals((1..10).toSet(), update.selectedIds)
        assertFalse(update.limitReached)
    }
}
