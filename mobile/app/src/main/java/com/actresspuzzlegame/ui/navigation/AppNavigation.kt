package com.actresspuzzlegame.ui.navigation

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.actresspuzzlegame.ui.screens.ActressSelectionScreen
import com.actresspuzzlegame.ui.screens.GameHomeScreen
import com.actresspuzzlegame.ui.screens.GameScreen
import com.actresspuzzlegame.ui.screens.LoginScreen
import com.actresspuzzlegame.ui.screens.SplashScreen

@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    val context = LocalContext.current
    val preferences = context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)

    fun selectedActressIds(): List<Int> = preferences
        .getString("selected_actress_ids", "")
        .orEmpty()
        .split(',')
        .mapNotNull { it.toIntOrNull() }

    fun authenticatedDestination(): String =
        if (selectedActressIds().isEmpty()) "actress_selection" else "home"

    NavHost(navController = navController, startDestination = "splash") {
        composable("splash") {
            SplashScreen(onSplashComplete = {
                val destination = if (preferences.getString("auth_token", "").isNullOrBlank()) {
                    "login"
                } else {
                    authenticatedDestination()
                }
                navController.navigate(destination) {
                    popUpTo("splash") { inclusive = true }
                }
            })
        }
        composable("login") {
            LoginScreen(onLoginSuccess = {
                navController.navigate(authenticatedDestination()) {
                    popUpTo("login") { inclusive = true }
                }
            })
        }
        composable("actress_selection") {
            ActressSelectionScreen(
                initialSelectedIds = selectedActressIds().toSet(),
                onSelectionConfirmed = { ids ->
                preferences.edit()
                    .putString("selected_actress_ids", ids.joinToString(","))
                    .apply()
                navController.navigate("home") {
                    popUpTo("actress_selection") { inclusive = true }
                    launchSingleTop = true
                }
            })
        }
        composable("home") {
            val ids = selectedActressIds()
            GameHomeScreen(
                actressIds = ids,
                onStartGame = {
                    val idsString = ids.joinToString(",")
                    navController.navigate("game/$idsString")
                },
                onChangeModel = { navController.navigate("actress_selection") }
            )
        }
        composable(
            route = "game/{actressIds}",
            arguments = listOf(navArgument("actressIds") { type = NavType.StringType })
        ) { backStackEntry ->
            val actressIdsString = backStackEntry.arguments?.getString("actressIds") ?: ""
            val actressIds = if (actressIdsString.isNotEmpty()) {
                actressIdsString.split(",").mapNotNull { it.toIntOrNull() }
            } else {
                emptyList()
            }
            GameScreen(
                actressIds = actressIds,
                onQuit = { navController.popBackStack("home", inclusive = false) },
                onSessionExpired = {
                    preferences.edit().remove("auth_token").apply()
                    navController.navigate("login") {
                        popUpTo(0) { inclusive = true }
                    }
                }
            )
        }
    }
}
