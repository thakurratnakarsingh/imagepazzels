package com.actresspuzzlegame.ui.theme

import android.app.Activity
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val BrandColorScheme = lightColorScheme(
    primary = BrandPurple,
    onPrimary = BrandCream,
    primaryContainer = Color(0xFFE8DAFF),
    onPrimaryContainer = BrandPurpleDark,
    secondary = BrandPink,
    onSecondary = BrandCream,
    tertiary = BrandGold,
    background = BrandPurpleDark,
    onBackground = BrandCream,
    surface = BrandCream,
    onSurface = BrandInk,
    surfaceVariant = Color(0xFFF3EAFB),
    onSurfaceVariant = BrandMuted,
    error = Color(0xFFD73D58)
)

@Composable
fun ActressPuzzleGameTheme(
    content: @Composable () -> Unit
) {
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = BrandPurpleDark.toArgb()
            window.navigationBarColor = BrandPurpleDark.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
            WindowCompat.getInsetsController(window, view).isAppearanceLightNavigationBars = false
        }
    }

    MaterialTheme(
        colorScheme = BrandColorScheme,
        content = content
    )
}
