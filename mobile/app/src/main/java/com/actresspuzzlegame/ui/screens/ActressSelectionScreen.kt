package com.actresspuzzlegame.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.layout.ContentScale
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.ui.draw.clip
import coil.compose.AsyncImage
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.network.ActressData

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ActressSelectionScreen(
    initialSelectedIds: Set<Int> = emptySet(),
    onSelectionConfirmed: (List<Int>) -> Unit
) {
    var actresses by remember { mutableStateOf<List<ActressData>>(emptyList()) }
    var selectedActressIds by remember(initialSelectedIds) { mutableStateOf(initialSelectedIds) }
    var isLoading by remember { mutableStateOf(true) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(Unit) {
        try {
            val response = ApiClient.service.getActresses()
            if (response.isSuccessful && response.body()?.success == true) {
                actresses = response.body()?.data?.filter { it.is_active } ?: emptyList()
            } else {
                errorMessage = "Failed to load actresses"
            }
        } catch (e: Exception) {
            errorMessage = e.message ?: "Network error"
        } finally {
            isLoading = false
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Choose Your Model") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = Color.White
                )
            )
        },
        bottomBar = {
            Button(
                onClick = { onSelectionConfirmed(selectedActressIds.toList()) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
                    .height(56.dp),
                enabled = selectedActressIds.isNotEmpty()
            ) {
                Text(
                    "CONTINUE (${selectedActressIds.size} SELECTED)",
                    fontWeight = FontWeight.Bold
                )
            }
        }
    ) { paddingValues ->
        Box(modifier = Modifier.padding(paddingValues).fillMaxSize()) {
            if (isLoading) {
                CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
            } else if (errorMessage != null) {
                Text(text = errorMessage!!, color = Color.Red, modifier = Modifier.align(Alignment.Center))
            } else if (actresses.isEmpty()) {
                Text(text = "No actresses available", modifier = Modifier.align(Alignment.Center))
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(actresses) { actress ->
                        val isSelected = selectedActressIds.contains(actress.id)
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable {
                                    selectedActressIds = if (isSelected) {
                                        selectedActressIds - actress.id
                                    } else {
                                        selectedActressIds + actress.id
                                    }
                                },
                            colors = CardDefaults.cardColors(
                                containerColor = if (isSelected) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.surfaceVariant
                            )
                        ) {
                            Row(
                                modifier = Modifier.padding(16.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                if (actress.thumbnail_image != null) {
                                    AsyncImage(
                                        model = "${com.actresspuzzlegame.network.ApiClient.BASE_SERVER_URL}uploads/actresses/thumbnails/${actress.thumbnail_image}",
                                        contentDescription = actress.name,
                                        modifier = Modifier
                                            .size(50.dp)
                                            .clip(CircleShape),
                                        contentScale = ContentScale.Crop
                                    )
                                    Spacer(modifier = Modifier.width(16.dp))
                                }
                                Text(
                                    text = actress.name,
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                                )
                                Spacer(modifier = Modifier.weight(1f))
                                if (isSelected) {
                                    Text("✓ Selected", color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
