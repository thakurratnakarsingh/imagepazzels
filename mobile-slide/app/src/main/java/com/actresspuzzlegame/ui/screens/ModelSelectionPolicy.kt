package com.actresspuzzlegame.ui.screens

const val MAX_SELECTED_MODELS = 10

data class ModelSelectionUpdate(
    val selectedIds: Set<Int>,
    val limitReached: Boolean
)

fun toggleModelSelection(currentIds: Set<Int>, modelId: Int): ModelSelectionUpdate {
    val normalizedIds = currentIds.take(MAX_SELECTED_MODELS).toSet()
    return when {
        modelId in normalizedIds -> ModelSelectionUpdate(
            selectedIds = normalizedIds - modelId,
            limitReached = false
        )
        normalizedIds.size < MAX_SELECTED_MODELS -> ModelSelectionUpdate(
            selectedIds = normalizedIds + modelId,
            limitReached = false
        )
        else -> ModelSelectionUpdate(
            selectedIds = normalizedIds,
            limitReached = true
        )
    }
}
