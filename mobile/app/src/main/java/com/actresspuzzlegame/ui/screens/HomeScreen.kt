package com.actresspuzzlegame.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.launch
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.network.ApiService
import com.actresspuzzlegame.network.GameLevelRequest
import com.actresspuzzlegame.network.LevelImageData
import android.content.Context
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.layout.ContentScale
import coil.compose.AsyncImage

@Composable
fun HomeScreen(actressIds: List<Int>) {
    var currentLevel by remember { mutableStateOf(1) }
    var currentImage by remember { mutableStateOf<LevelImageData?>(null) }
    var isLoading by remember { mutableStateOf(true) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    val context = LocalContext.current
    val sharedPref = context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
    val token = sharedPref.getString("auth_token", "") ?: ""

    LaunchedEffect(currentLevel) {
        isLoading = true
        errorMessage = null
        try {
            val apiService = ApiClient.getClient().create(ApiService::class.java)
            val request = GameLevelRequest(level = currentLevel, actress_ids = actressIds)
            val response = apiService.getGameLevelImage("Bearer $token", request)
            
            if (response.isSuccessful && response.body() != null) {
                currentImage = response.body()?.image
            } else if (response.code() == 404) {
                errorMessage = "No more levels available for the selected actresses!"
                currentImage = null
            } else {
                errorMessage = "Failed to load level ${currentLevel}"
            }
        } catch (e: Exception) {
            errorMessage = e.message ?: "Network error"
        } finally {
            isLoading = false
        }
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("Level $currentLevel", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(16.dp))

        if (isLoading) {
            CircularProgressIndicator()
        } else if (errorMessage != null) {
            Text(errorMessage!!, color = Color.Red, style = MaterialTheme.typography.titleMedium)
        } else if (currentImage != null) {
            Card(
                modifier = Modifier.fillMaxWidth().height(300.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.secondaryContainer)
            ) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    AsyncImage(
                        model = currentImage!!.image_url,
                        contentDescription = "Level Image",
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(32.dp))
            Button(
                onClick = { currentLevel++ },
                modifier = Modifier.fillMaxWidth().height(56.dp)
            ) {
                Text("Complete Level & Next", fontWeight = FontWeight.Bold)
            }
        }
    }
}
