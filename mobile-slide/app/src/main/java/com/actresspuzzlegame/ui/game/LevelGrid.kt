package com.actresspuzzlegame.ui.game

fun gridSizeForLevel(level: Int): Int = when {
    level <= 25 -> 3
    level <= 50 -> 4
    else -> 5
}
