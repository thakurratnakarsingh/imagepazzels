package com.actresspuzzlegame.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.actresspuzzlegame.ui.screens.ActressSelectionScreen
import com.actresspuzzlegame.ui.screens.HomeScreen
import com.actresspuzzlegame.ui.screens.LoginScreen
import com.actresspuzzlegame.ui.screens.SplashScreen

@Composable
fun AppNavigation() {
    val navController = rememberNavController()

    NavHost(navController = navController, startDestination = "splash") {
        composable("splash") {
            SplashScreen(onSplashComplete = {
                navController.navigate("login") {
                    popUpTo("splash") { inclusive = true }
                }
            })
        }
        composable("login") {
            LoginScreen(onLoginSuccess = {
                navController.navigate("actress_selection") {
                    popUpTo("login") { inclusive = true }
                }
            })
        }
        composable("actress_selection") {
            ActressSelectionScreen(onNavigateToGame = { ids ->
                val idsString = ids.joinToString(",")
                navController.navigate("game/$idsString")
            })
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
            HomeScreen(
                actressIds = actressIds,
                onQuit = { navController.popBackStack("actress_selection", inclusive = false) },
                onSessionExpired = {
                    navController.navigate("login") {
                        popUpTo("game/{actressIds}") { inclusive = true }
                    }
                }
            )
        }
    }
}
