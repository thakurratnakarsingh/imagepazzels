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

private val PremiumColorScheme = lightColorScheme(
    primary = PremiumPrimary,
    onPrimary = PremiumTextWhite,
    primaryContainer = PremiumPrimaryLight,
    onPrimaryContainer = PremiumTextWhite,
    secondary = PremiumAccent,
    onSecondary = PremiumTextDark,
    tertiary = PremiumGold,
    background = PremiumBackgroundDark,
    onBackground = PremiumTextWhite,
    surface = PremiumSurface,
    onSurface = PremiumTextWhite,
    surfaceVariant = PremiumSurfaceHighlight,
    onSurfaceVariant = PremiumTextGray,
    error = PremiumWarning
)

@Composable
fun ActressPuzzleGameTheme(
    content: @Composable () -> Unit
) {
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = PremiumBackgroundDark.toArgb()
            window.navigationBarColor = PremiumBackgroundDark.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
            WindowCompat.getInsetsController(window, view).isAppearanceLightNavigationBars = false
        }
    }

    MaterialTheme(
        colorScheme = PremiumColorScheme,
        content = content
    )
}
