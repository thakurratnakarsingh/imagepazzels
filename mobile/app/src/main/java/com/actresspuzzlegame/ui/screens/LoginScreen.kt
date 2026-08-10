package com.actresspuzzlegame.ui.screens

import android.content.Context
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.network.ApiService
import kotlinx.coroutines.launch

@Composable
fun LoginScreen(onLoginSuccess: () -> Unit) {
    val context = LocalContext.current
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    val coroutineScope = rememberCoroutineScope()

    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text("Welcome to Actress Puzzle Game")
        
        if (errorMessage != null) {
            Text(text = errorMessage!!, color = androidx.compose.ui.graphics.Color.Red)
        }

        if (isLoading) {
            CircularProgressIndicator()
        } else {
            Button(onClick = { 
                isLoading = true
                errorMessage = null
                coroutineScope.launch {
                    try {
                        val apiService = ApiClient.getClient().create(ApiService::class.java)
                        val response = apiService.guestLogin()
                        
                        if (response.isSuccessful && response.body()?.success == true) {
                            val token = response.body()?.data?.accessToken ?: ""
                            val sharedPref = context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
                            with (sharedPref.edit()) {
                                putString("auth_token", token)
                                apply()
                            }
                            onLoginSuccess()
                        } else {
                            errorMessage = "Login failed: ${response.message()}"
                        }
                    } catch (e: Exception) {
                        errorMessage = "Network error: ${e.message}"
                    } finally {
                        isLoading = false
                    }
                }
            }) {
                Text("Play as Guest")
            }
        }
    }
}

