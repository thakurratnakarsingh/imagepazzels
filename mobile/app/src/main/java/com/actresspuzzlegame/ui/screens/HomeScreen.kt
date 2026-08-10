package com.actresspuzzlegame.ui.screens

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.actresspuzzlegame.network.ApiClient
import com.actresspuzzlegame.network.CompleteLevelRequest
import com.actresspuzzlegame.network.GameLevelRequest
import com.actresspuzzlegame.network.GameLevelResponse
import com.actresspuzzlegame.network.SaveProgressRequest
import com.actresspuzzlegame.ui.game.PuzzleScreen
import com.actresspuzzlegame.ui.game.PuzzleViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.cos
import kotlin.math.sin

private val GameBlue = Color(0xFF4D8BC2)
private val GameBlueDark = Color(0xFF315F9F)
private val PanelBlue = Color(0xFF326FC1)

@Composable
fun GameScreen(
    actressIds: List<Int>,
    onQuit: () -> Unit,
    onSessionExpired: () -> Unit
) {
    val context = LocalContext.current
    val preferences = remember {
        context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
    }
    val token = remember { preferences.getString("auth_token", "").orEmpty() }
    var currentLevel by remember {
        mutableIntStateOf(preferences.getInt("current_level", 1).coerceAtLeast(1))
    }
    var gameData by remember { mutableStateOf<GameLevelResponse?>(null) }
    var isLoading by remember { mutableStateOf(true) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var showSettings by remember { mutableStateOf(false) }
    var completion by remember { mutableStateOf<CompletionUi?>(null) }
    var completionSubmitting by remember { mutableStateOf(false) }
    var statusMessage by remember { mutableStateOf<String?>(null) }
    var supportEmail by remember { mutableStateOf("support@example.com") }
    var showPrivacyPolicy by remember { mutableStateOf(false) }
    var privacyPolicyText by remember { mutableStateOf<String?>(null) }
    var elapsedSeconds by remember { mutableIntStateOf(0) }
    var musicEnabled by remember { mutableStateOf(preferences.getBoolean("music_enabled", true)) }
    var soundEnabled by remember { mutableStateOf(preferences.getBoolean("sound_enabled", true)) }
    var vibrationEnabled by remember { mutableStateOf(preferences.getBoolean("vibration_enabled", true)) }
    val puzzleViewModel = remember { PuzzleViewModel() }
    val puzzleState by puzzleViewModel.state.collectAsState()
    val scope = rememberCoroutineScope()

    fun persistSettings() {
        preferences.edit()
            .putBoolean("music_enabled", musicEnabled)
            .putBoolean("sound_enabled", soundEnabled)
            .putBoolean("vibration_enabled", vibrationEnabled)
            .apply()
    }

    fun loadLevel() {
        scope.launch {
            isLoading = true
            errorMessage = null
            gameData = null
            completion = null
            completionSubmitting = false
            elapsedSeconds = 0
            try {
                val response = ApiClient.service.getGameLevelImage(
                    authHeader = "Bearer $token",
                    request = GameLevelRequest(currentLevel, actressIds)
                )
                when {
                    response.isSuccessful && response.body() != null -> {
                        gameData = response.body()
                        elapsedSeconds = response.body()?.saved_progress?.elapsed_time_seconds ?: 0
                    }
                    response.code() == 401 || response.code() == 403 -> onSessionExpired()
                    response.code() == 404 -> errorMessage =
                        "No image has been uploaded for Level $currentLevel and your selection."
                    else -> errorMessage = "Level $currentLevel could not be loaded. Please try again."
                }
            } catch (_: Exception) {
                errorMessage = "Cannot reach the game server. Check the API address and connection."
            } finally {
                isLoading = false
            }
        }
    }

    LaunchedEffect(currentLevel, actressIds) { loadLevel() }

    LaunchedEffect(Unit) {
        runCatching { ApiClient.service.getMobileConfig() }
            .getOrNull()
            ?.body()
            ?.data
            ?.get("support_email")
            ?.toString()
            ?.takeIf { it.isNotBlank() }
            ?.let { supportEmail = it }
    }

    LaunchedEffect(gameData, puzzleState.isCompleted) {
        while (gameData != null && !puzzleState.isCompleted) {
            delay(1_000)
            elapsedSeconds++
        }
    }

    val saveProgress: () -> Unit = {
        val data = gameData
        val sessionId = data?.session_id
        val levelId = data?.level_id
        if (data == null || sessionId == null || levelId == null) {
            statusMessage = "This level cannot be saved yet. Reconnect and try again."
        } else {
            scope.launch {
                try {
                    val response = ApiClient.service.saveProgress(
                        "Bearer $token",
                        SaveProgressRequest(
                            levelId = levelId,
                            sessionId = sessionId,
                            tileArrangement = puzzleViewModel.tileArrangement(),
                            emptyTileIndex = puzzleState.emptyTilePosition,
                            moveCount = puzzleState.moveCount,
                            elapsedTimeSeconds = elapsedSeconds
                        )
                    )
                    statusMessage = if (response.isSuccessful) {
                        "Progress saved"
                    } else {
                        "Progress could not be saved"
                    }
                } catch (_: Exception) {
                    statusMessage = "Progress could not be saved while offline"
                }
            }
        }
    }

    fun completeLevel() {
        if (completionSubmitting || completion != null) return
        completionSubmitting = true
        puzzleViewModel.setInteractionEnabled(false)
        val data = gameData
        val threeStarLimit = data?.max_moves_3_stars ?: (puzzleState.tiles.size * 3)
        val twoStarLimit = data?.max_moves_2_stars ?: (puzzleState.tiles.size * 5)
        val localStars = when {
            puzzleState.moveCount <= threeStarLimit -> 3
            puzzleState.moveCount <= twoStarLimit -> 2
            else -> 1
        }
        val completedLevel = currentLevel
        completion = CompletionUi(
            stars = localStars,
            reward = data?.reward_points ?: 0,
            moves = puzzleState.moveCount,
            seconds = elapsedSeconds
        )
        preferences.edit().putInt("current_level", currentLevel + 1).apply()

        scope.launch {
            var reward = data?.reward_points ?: 0
            var stars = localStars
            val sessionId = data?.session_id
            val levelId = data?.level_id
            if (data != null && sessionId != null && levelId != null) {
                try {
                    val response = ApiClient.service.completeLevel(
                        "Bearer $token",
                        CompleteLevelRequest(
                            levelId = levelId,
                            imageId = data.image.id,
                            moves = puzzleState.moveCount,
                            timeTakenSeconds = elapsedSeconds,
                            puzzleSessionId = sessionId
                        )
                    )
                    if (response.isSuccessful) {
                        reward = response.body()?.data?.rewardPointsEarned ?: reward
                        stars = response.body()?.data?.stars ?: stars
                    }
                } catch (_: Exception) {
                    statusMessage = "Completed offline; server sync will be available after reconnecting."
                }
            }

            if (currentLevel == completedLevel && completion != null) {
                completion = CompletionUi(stars, reward, puzzleState.moveCount, elapsedSeconds)
            }
            completionSubmitting = false
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    listOf(GameBlue, Color(0xFF7C98C3))
                )
            )
            .statusBarsPadding()
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 22.dp, end = 22.dp, top = 14.dp, bottom = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Level $currentLevel",
                    color = Color.White,
                    fontSize = 30.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(Modifier.weight(1f))
                Box(
                    modifier = Modifier
                        .size(54.dp)
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.32f))
                        .clickable { showSettings = true },
                    contentAlignment = Alignment.Center
                ) {
                    Text("⚙", color = Color(0xFF0D7281), fontSize = 31.sp)
                }
            }

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(min = if (gameData == null) 320.dp else 0.dp)
                    .padding(horizontal = 18.dp),
                contentAlignment = Alignment.TopCenter
            ) {
                when {
                    isLoading -> CircularProgressIndicator(
                        color = Color.White,
                        modifier = Modifier.align(Alignment.Center).padding(vertical = 120.dp)
                    )
                    errorMessage != null -> ErrorState(
                        message = errorMessage.orEmpty(),
                        onRetry = ::loadLevel,
                        modifier = Modifier.align(Alignment.Center)
                    )
                    gameData != null -> {
                        val data = gameData!!
                        val fallbackSize = gridSizeForLevel(currentLevel)
                        PuzzleScreen(
                            viewModel = puzzleViewModel,
                            imageUrl = data.image.image_url,
                            rows = (data.rows ?: fallbackSize).coerceIn(2, 8),
                            columns = (data.columns ?: fallbackSize).coerceIn(2, 8),
                            shuffleMoves = data.shuffle_moves ?: fallbackSize * fallbackSize * 8,
                            savedArrangement = data.saved_progress?.tile_arrangement,
                            savedMoveCount = data.saved_progress?.move_count ?: 0,
                            soundEnabled = soundEnabled,
                            vibrationEnabled = vibrationEnabled,
                            onCompleted = ::completeLevel
                        )
                    }
                }
            }

            Text(
                text = "${puzzleState.moveCount} moves  •  ${formatTime(elapsedSeconds)}",
                color = Color.White.copy(alpha = 0.9f),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 10.dp, bottom = 8.dp),
                textAlign = TextAlign.Center,
                fontWeight = FontWeight.SemiBold,
                fontSize = 17.sp
            )

            completion?.let { result ->
                CompletionPanel(result) {
                    completion = null
                    currentLevel++
                }
            }
            Spacer(Modifier.weight(1f))
        }

        if (completion != null) FireworksOverlay()
    }

    if (showSettings) {
        SettingsDialog(
            musicEnabled = musicEnabled,
            soundEnabled = soundEnabled,
            vibrationEnabled = vibrationEnabled,
            statusMessage = statusMessage,
            onMusicChange = { musicEnabled = it; persistSettings() },
            onSoundChange = { soundEnabled = it; persistSettings() },
            onVibrationChange = { vibrationEnabled = it; persistSettings() },
            onSaveProgress = saveProgress,
            onSupport = {
                openUrl(context, "mailto:$supportEmail?subject=Puzzle%20Game%20Support")
            },
            onPrivacy = {
                showPrivacyPolicy = true
                privacyPolicyText = null
                scope.launch {
                    privacyPolicyText = try {
                        val response = ApiClient.service.getPrivacyPolicy()
                        response.body()?.data?.content
                            ?: "The privacy policy is currently unavailable."
                    } catch (_: Exception) {
                        "The privacy policy could not be loaded while offline."
                    }
                }
            },
            onQuit = { showSettings = false; onQuit() },
            onDismiss = { showSettings = false; statusMessage = null }
        )
    }

    if (showPrivacyPolicy) {
        PrivacyPolicyDialog(
            content = privacyPolicyText,
            onDismiss = { showPrivacyPolicy = false }
        )
    }
}

@Composable
private fun SettingsDialog(
    musicEnabled: Boolean,
    soundEnabled: Boolean,
    vibrationEnabled: Boolean,
    statusMessage: String?,
    onMusicChange: (Boolean) -> Unit,
    onSoundChange: (Boolean) -> Unit,
    onVibrationChange: (Boolean) -> Unit,
    onSaveProgress: () -> Unit,
    onSupport: () -> Unit,
    onPrivacy: () -> Unit,
    onQuit: () -> Unit,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = PanelBlue,
        shape = RoundedCornerShape(24.dp),
        title = {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Settings", color = Color.White, fontSize = 30.sp, fontWeight = FontWeight.Bold)
                Spacer(Modifier.weight(1f))
                Text(
                    "×",
                    color = Color(0xFF153F78),
                    fontSize = 38.sp,
                    modifier = Modifier.clickable(onClick = onDismiss)
                )
            }
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Surface(color = GameBlueDark, shape = RoundedCornerShape(16.dp)) {
                    Column(Modifier.padding(horizontal = 16.dp, vertical = 10.dp)) {
                        SettingSwitch("Music", musicEnabled, onMusicChange)
                        SettingSwitch("Sound", soundEnabled, onSoundChange)
                        SettingSwitch("Vibration", vibrationEnabled, onVibrationChange)
                    }
                }
                SettingsButton("▣  Save Progress", onSaveProgress)
                SettingsButton("✉  Support", onSupport)
                Button(
                    onClick = onQuit,
                    modifier = Modifier.fillMaxWidth().height(52.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFD64150)),
                    shape = RoundedCornerShape(14.dp)
                ) {
                    Text("Quit", fontSize = 20.sp, fontWeight = FontWeight.Bold)
                }
                statusMessage?.let {
                    Text(it, color = Color.White, textAlign = TextAlign.Center, modifier = Modifier.fillMaxWidth())
                }
                Text(
                    "Privacy Policy",
                    color = Color(0xFF173E78),
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth().clickable(onClick = onPrivacy)
                )
            }
        },
        confirmButton = {}
    )
}

@Composable
private fun SettingSwitch(label: String, checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(label, color = Color(0xFFBAF6F0), fontSize = 18.sp, fontWeight = FontWeight.Bold)
        Spacer(Modifier.weight(1f))
        Switch(checked = checked, onCheckedChange = onCheckedChange)
    }
}

@Composable
private fun SettingsButton(label: String, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth().height(52.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = Color(0xFFFFF7F0),
            contentColor = Color(0xFF164E9A)
        ),
        shape = RoundedCornerShape(14.dp)
    ) {
        Text(label, fontSize = 18.sp, fontWeight = FontWeight.Bold)
    }
}

@Composable
private fun ErrorState(message: String, onRetry: () -> Unit, modifier: Modifier = Modifier) {
    Column(modifier = modifier.padding(28.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        Text(message, color = Color.White, textAlign = TextAlign.Center, fontSize = 18.sp)
        Spacer(Modifier.height(16.dp))
        Button(onClick = onRetry) { Text("Retry") }
    }
}

@Composable
private fun CompletionPanel(result: CompletionUi, onNext: () -> Unit) {
    Surface(
        modifier = Modifier.fillMaxWidth().padding(horizontal = 18.dp, vertical = 4.dp),
        color = Color(0xFFFFF8F1),
        shape = RoundedCornerShape(20.dp),
        shadowElevation = 10.dp
    ) {
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text("Puzzle complete!", color = Color(0xFF244A80), fontWeight = FontWeight.Black, fontSize = 18.sp)
                Text(
                    "★".repeat(result.stars) + "☆".repeat(3 - result.stars),
                    color = Color(0xFFFFB300),
                    fontSize = 24.sp
                )
                Text(
                    "${result.moves} moves • ${formatTime(result.seconds)}" +
                        if (result.reward > 0) " • +${result.reward} points" else "",
                    color = Color(0xFF51637B),
                    fontSize = 12.sp
                )
            }
            Button(
                onClick = onNext,
                shape = RoundedCornerShape(16.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFF8A3D))
            ) {
                Text("NEXT  ▶", fontWeight = FontWeight.Black)
            }
        }
    }
}

@Composable
private fun FireworksOverlay() {
    val transition = rememberInfiniteTransition(label = "fireworks")
    val progress by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(animation = tween(1_700)),
        label = "fireworks_progress"
    )
    val colors = remember {
        listOf(Color(0xFFFFD740), Color(0xFFFF4081), Color(0xFF69F0AE), Color(0xFF40C4FF), Color.White)
    }

    Canvas(Modifier.fillMaxSize()) {
        val bursts = listOf(
            Offset(size.width * 0.18f, size.height * 0.20f) to 0f,
            Offset(size.width * 0.82f, size.height * 0.28f) to 0.34f,
            Offset(size.width * 0.52f, size.height * 0.12f) to 0.68f
        )
        bursts.forEachIndexed { burstIndex, (center, phase) ->
            val burstProgress = (progress + phase) % 1f
            val alpha = (1f - burstProgress).coerceIn(0f, 1f)
            val radius = size.minDimension * 0.34f * burstProgress
            repeat(18) { particle ->
                val angle = (Math.PI * 2.0 * particle / 18.0) + burstIndex * 0.25
                val direction = Offset(cos(angle).toFloat(), sin(angle).toFloat())
                val end = center + direction * radius
                val tail = end - direction * (10f + 18f * (1f - burstProgress))
                val color = colors[(particle + burstIndex) % colors.size].copy(alpha = alpha)
                drawLine(color, tail, end, strokeWidth = 5f, cap = StrokeCap.Round)
                drawCircle(color, radius = 4.5f, center = end)
            }
        }

        repeat(26) { index ->
            val x = ((index * 47f) % size.width)
            val y = ((progress * size.height * 1.25f + index * 83f) % size.height)
            drawLine(
                color = colors[index % colors.size].copy(alpha = 0.8f),
                start = Offset(x, y),
                end = Offset(x + if (index % 2 == 0) 9f else -9f, y + 15f),
                strokeWidth = 6f,
                cap = StrokeCap.Round
            )
        }
    }
}

@Composable
private fun PrivacyPolicyDialog(content: String?, onDismiss: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Privacy Policy", fontWeight = FontWeight.Bold) },
        text = {
            if (content == null) {
                Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator()
                }
            } else {
                Text(
                    content,
                    modifier = Modifier.verticalScroll(rememberScrollState())
                )
            }
        },
        confirmButton = { TextButton(onClick = onDismiss) { Text("Close") } }
    )
}

private data class CompletionUi(val stars: Int, val reward: Int, val moves: Int, val seconds: Int)

private fun gridSizeForLevel(level: Int): Int = when {
    level <= 2 -> 3
    level <= 5 -> 4
    level <= 25 -> 5
    level <= 100 -> 6
    else -> 7
}

private fun formatTime(totalSeconds: Int): String =
    "%02d:%02d".format(totalSeconds / 60, totalSeconds % 60)

private fun openUrl(context: Context, url: String) {
    runCatching {
        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
    }
}
