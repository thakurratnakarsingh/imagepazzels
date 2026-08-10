package com.actresspuzzlegame.ui.screens

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import coil.compose.AsyncImage
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.network.SplashData
import kotlinx.coroutines.delay
import androidx.compose.ui.layout.ContentScale

@Composable
fun SplashScreen(onSplashComplete: () -> Unit) {
    val splashData = remember { mutableStateOf<SplashData?>(null) }
    val isLoading = remember { mutableStateOf(true) }

    LaunchedEffect(Unit) {
        try {
            val response = ApiClient.service.getActiveSplash()
            if (response.isSuccessful && response.body() != null) {
                splashData.value = response.body()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            isLoading.value = false
        }

        // Use dynamically fetched duration (in seconds), or default to 3 seconds if fetch failed
        val durationSeconds = splashData.value?.time ?: 3
        delay((durationSeconds * 1000).toLong())
        onSplashComplete()
    }

    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        val data = splashData.value
        if (data != null) {
            // Display dynamically fetched Splash Screen image
            AsyncImage(
                model = data.image,
                contentDescription = data.name,
                modifier = Modifier.fillMaxSize(),
                contentScale = ContentScale.Crop
            )
        } else {
            // Fallback screen if there's no active splash or network issue
            if (isLoading.value) {
                CircularProgressIndicator()
            } else {
                Text("Actress Puzzle Game")
            }
        }
    }
}
