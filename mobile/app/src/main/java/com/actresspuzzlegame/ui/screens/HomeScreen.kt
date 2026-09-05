package com.actresspuzzlegame.ui.screens

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.CircularProgressIndicator
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
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
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
import com.actresspuzzlegame.ui.theme.PremiumAccent
import com.actresspuzzlegame.ui.theme.PremiumBackgroundDark
import com.actresspuzzlegame.ui.theme.PremiumGold
import com.actresspuzzlegame.ui.theme.PremiumGoldLight
import com.actresspuzzlegame.ui.theme.PremiumGradientAccent
import com.actresspuzzlegame.ui.theme.PremiumGradientGold
import com.actresspuzzlegame.ui.theme.PremiumPrimary
import com.actresspuzzlegame.ui.theme.PremiumPrimaryLight
import com.actresspuzzlegame.ui.theme.PremiumStroke
import com.actresspuzzlegame.ui.theme.PremiumSuccess
import com.actresspuzzlegame.ui.theme.PremiumSurface
import com.actresspuzzlegame.ui.theme.PremiumSurfaceHighlight
import com.actresspuzzlegame.ui.theme.PremiumTextDark
import com.actresspuzzlegame.ui.theme.PremiumTextGray
import com.actresspuzzlegame.ui.theme.PremiumTextWhite
import com.actresspuzzlegame.ui.theme.PremiumWarning
import com.actresspuzzlegame.ui.theme.PremiumWarningDark
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.cos
import kotlin.math.sin

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
    var showTutorial by remember { mutableStateOf(!preferences.getBoolean("game_tutorial_seen", false)) }
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

    LaunchedEffect(gameData, puzzleState.isCompleted, showTutorial) {
        while (gameData != null && !puzzleState.isCompleted && !showTutorial) {
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

    fun dismissTutorial() {
        preferences.edit().putBoolean("game_tutorial_seen", true).apply()
        showTutorial = false
    }

    BackHandler(enabled = showTutorial && gameData != null, onBack = ::dismissTutorial)

    PremiumGameBackground(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            GameTopBar(
                currentLevel = currentLevel,
                onPause = { showSettings = true }
            )

            GameHudRow(
                moves = puzzleState.moveCount,
                time = formatTime(elapsedSeconds),
                reward = gameData?.reward_points
            )

            BoxWithConstraints(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 14.dp, vertical = 10.dp),
                contentAlignment = Alignment.Center
            ) {
                val availableWidth = maxWidth - 8.dp
                val boardWidthFromHeight = maxHeight * 0.70f
                val boardWidth = if (boardWidthFromHeight < availableWidth) {
                    boardWidthFromHeight
                } else {
                    availableWidth
                }.coerceAtLeast(1.dp)

                Box(
                    modifier = Modifier.width(boardWidth),
                    contentAlignment = Alignment.Center
                ) {
                    when {
                        isLoading -> PremiumLoadingState()
                        errorMessage != null -> ErrorState(
                            message = errorMessage.orEmpty(),
                            onRetry = ::loadLevel
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
            }
        }

        completion?.let { result ->
            FireworksOverlay()
            CompletionOverlay(
                result = result,
                level = currentLevel,
                onNext = {
                    completion = null
                    puzzleViewModel.setInteractionEnabled(true)
                    currentLevel++
                },
                onReplay = {
                    completion = null
                    puzzleViewModel.setInteractionEnabled(true)
                    loadLevel()
                },
                onHome = {
                    completion = null
                    onQuit()
                },
                onShare = { shareCompletion(context, currentLevel, result) }
            )
        }

        if (showTutorial && gameData != null) {
            GameTutorialOverlay(onDismiss = ::dismissTutorial)
        }
    }

    if (showSettings) {
        PauseSettingsDialog(
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
private fun GameTopBar(
    currentLevel: Int,
    onPause: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(start = 20.dp, end = 20.dp, top = 14.dp, bottom = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Text(
                text = "IMAGE PUZZLE",
                color = PremiumTextGray,
                fontSize = 10.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = 1.3.sp
            )
            Text(
                text = "Level $currentLevel",
                color = PremiumTextWhite,
                fontSize = 30.sp,
                fontWeight = FontWeight.Black
            )
        }
        Spacer(Modifier.weight(1f))
        PremiumIconButton(
            icon = GameIcon.Settings,
            onClick = onPause,
            color = PremiumTextWhite,
            contentDescription = "Pause"
        )
    }
}

@Composable
private fun GameHudRow(
    moves: Int,
    time: String,
    reward: Int?
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 14.dp),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        PremiumStatChip(
            label = "Moves",
            value = moves.toString(),
            modifier = Modifier.weight(1f),
            accentColor = PremiumGold
        )
        PremiumStatChip(
            label = "Time",
            value = time,
            modifier = Modifier.weight(1f),
            accentColor = PremiumAccent
        )
        PremiumStatChip(
            label = "Reward",
            value = reward?.takeIf { it > 0 }?.let { "+$it" } ?: "--",
            modifier = Modifier.weight(1f),
            accentColor = PremiumSuccess
        )
    }
}

@Composable
private fun PremiumLoadingState() {
    PremiumPanel(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 280.dp),
        shape = RoundedCornerShape(24.dp),
        elevated = false
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 44.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(70.dp)
                    .clip(RoundedCornerShape(18.dp))
                    .background(Brush.verticalGradient(PremiumGradientAccent)),
                contentAlignment = Alignment.Center
            ) {
                GameIconCanvas(GameIcon.Puzzle, PremiumTextDark, Modifier.size(36.dp))
            }
            Spacer(Modifier.height(18.dp))
            CircularProgressIndicator(color = PremiumAccent, strokeWidth = 3.dp)
        }
    }
}

@Composable
private fun PauseSettingsDialog(
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
        containerColor = PremiumBackgroundDark,
        shape = RoundedCornerShape(28.dp),
        title = {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column {
                    Text(
                        text = "PAUSED",
                        color = PremiumGold,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Black,
                        letterSpacing = 1.4.sp
                    )
                    Text(
                        text = "Settings",
                        color = PremiumTextWhite,
                        fontSize = 26.sp,
                        fontWeight = FontWeight.Black
                    )
                }
                Spacer(Modifier.weight(1f))
                PremiumIconButton(
                    icon = GameIcon.Close,
                    onClick = onDismiss,
                    size = 44.dp,
                    color = PremiumTextWhite,
                    contentDescription = "Close pause menu"
                )
            }
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                PremiumGameButton(
                    text = "RESUME",
                    onClick = onDismiss,
                    icon = GameIcon.Play,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(54.dp),
                    primaryColor = PremiumGoldLight,
                    secondaryColor = PremiumGold,
                    textColor = PremiumTextDark
                )
                PremiumPanel(shape = RoundedCornerShape(18.dp), elevated = false) {
                    Column(Modifier.padding(horizontal = 16.dp, vertical = 10.dp)) {
                        SettingSwitch("Music", musicEnabled, onMusicChange)
                        SettingSwitch("Sound", soundEnabled, onSoundChange)
                        SettingSwitch("Vibration", vibrationEnabled, onVibrationChange)
                    }
                }
                PremiumGameButton(
                    text = "SAVE PROGRESS",
                    onClick = onSaveProgress,
                    icon = GameIcon.Save,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    primaryColor = PremiumSurfaceHighlight,
                    secondaryColor = PremiumSurface,
                    textColor = PremiumTextWhite
                )
                PremiumGameButton(
                    text = "SUPPORT",
                    onClick = onSupport,
                    icon = GameIcon.Mail,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    primaryColor = PremiumSurfaceHighlight,
                    secondaryColor = PremiumSurface,
                    textColor = PremiumTextWhite
                )
                PremiumGameButton(
                    text = "EXIT TO HOME",
                    onClick = onQuit,
                    icon = GameIcon.Home,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp),
                    primaryColor = PremiumWarning,
                    secondaryColor = PremiumWarningDark,
                    textColor = PremiumTextWhite
                )
                statusMessage?.let {
                    Text(
                        text = it,
                        color = PremiumTextWhite,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
                Text(
                    text = "Privacy Policy",
                    color = PremiumAccent,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center,
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable(onClick = onPrivacy)
                        .padding(vertical = 4.dp)
                )
            }
        },
        confirmButton = {}
    )
}

@Composable
private fun SettingSwitch(label: String, checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            color = PremiumTextWhite,
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold
        )
        Spacer(Modifier.weight(1f))
        Switch(checked = checked, onCheckedChange = onCheckedChange)
    }
}

@Composable
private fun ErrorState(message: String, onRetry: () -> Unit, modifier: Modifier = Modifier) {
    PremiumPanel(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        elevated = false
    ) {
        Column(
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 22.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = message,
                color = PremiumWarning,
                textAlign = TextAlign.Center,
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold
            )
            Spacer(Modifier.height(16.dp))
            PremiumGameButton(
                text = "RETRY",
                onClick = onRetry,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
            )
        }
    }
}

@Composable
private fun CompletionOverlay(
    result: CompletionUi,
    level: Int,
    onNext: () -> Unit,
    onReplay: () -> Unit,
    onHome: () -> Unit,
    onShare: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(PremiumBackgroundDark.copy(alpha = 0.72f))
            .padding(22.dp),
        contentAlignment = Alignment.Center
    ) {
        PremiumPanel(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(30.dp)
        ) {
            Column(
                modifier = Modifier.padding(horizontal = 22.dp, vertical = 24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Box(
                    modifier = Modifier
                        .size(74.dp)
                        .clip(CircleShape)
                        .background(Brush.verticalGradient(PremiumGradientGold)),
                    contentAlignment = Alignment.Center
                ) {
                    GameIconCanvas(GameIcon.Check, PremiumTextDark, Modifier.size(38.dp))
                }
                Spacer(Modifier.height(14.dp))
                Text(
                    text = "PUZZLE COMPLETE",
                    color = PremiumGold,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Black,
                    letterSpacing = 1.5.sp
                )
                Text(
                    text = "Level $level",
                    color = PremiumTextWhite,
                    fontSize = 32.sp,
                    fontWeight = FontWeight.Black
                )
                PremiumStars(
                    stars = result.stars,
                    modifier = Modifier.padding(top = 8.dp, bottom = 18.dp),
                    starSize = 34.dp
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    ResultStat("Moves", result.moves.toString(), Modifier.weight(1f))
                    ResultStat("Time", formatTime(result.seconds), Modifier.weight(1f))
                    ResultStat("Reward", if (result.reward > 0) "+${result.reward}" else "--", Modifier.weight(1f))
                }

                Spacer(Modifier.height(20.dp))
                PremiumGameButton(
                    text = "NEXT PUZZLE",
                    onClick = onNext,
                    icon = GameIcon.Play,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(58.dp),
                    primaryColor = PremiumGoldLight,
                    secondaryColor = PremiumGold,
                    textColor = PremiumTextDark
                )
                Spacer(Modifier.height(10.dp))
                PremiumGameButton(
                    text = "PLAY AGAIN",
                    onClick = onReplay,
                    icon = GameIcon.Replay,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(54.dp),
                    primaryColor = PremiumSurfaceHighlight,
                    secondaryColor = PremiumSurface,
                    textColor = PremiumTextWhite
                )
                Spacer(Modifier.height(10.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    PremiumGameButton(
                        text = "HOME",
                        onClick = onHome,
                        icon = GameIcon.Home,
                        modifier = Modifier
                            .weight(1f)
                            .height(52.dp),
                        primaryColor = PremiumSurfaceHighlight,
                        secondaryColor = PremiumSurface,
                        textColor = PremiumTextWhite
                    )
                    PremiumGameButton(
                        text = "SHARE",
                        onClick = onShare,
                        icon = GameIcon.Share,
                        modifier = Modifier
                            .weight(1f)
                            .height(52.dp),
                        primaryColor = PremiumSurfaceHighlight,
                        secondaryColor = PremiumSurface,
                        textColor = PremiumTextWhite
                    )
                }
            }
        }
    }
}

@Composable
private fun ResultStat(label: String, value: String, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(16.dp))
            .background(PremiumSurfaceHighlight.copy(alpha = 0.62f))
            .padding(horizontal = 8.dp, vertical = 10.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = label.uppercase(),
                color = PremiumTextGray,
                fontSize = 9.sp,
                fontWeight = FontWeight.Black
            )
            Text(
                text = value,
                color = PremiumTextWhite,
                fontSize = 16.sp,
                fontWeight = FontWeight.Black
            )
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
        listOf(PremiumGold, PremiumPrimaryLight, PremiumAccent, PremiumSuccess, Color.White)
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
            val radius = size.minDimension * 0.30f * burstProgress
            repeat(14) { particle ->
                val angle = (Math.PI * 2.0 * particle / 14.0) + burstIndex * 0.25
                val direction = Offset(cos(angle).toFloat(), sin(angle).toFloat())
                val end = center + direction * radius
                val tail = end - direction * (8f + 14f * (1f - burstProgress))
                val color = colors[(particle + burstIndex) % colors.size].copy(alpha = alpha)
                drawLine(color, tail, end, strokeWidth = 4f, cap = StrokeCap.Round)
                drawCircle(color, radius = 3.8f, center = end)
            }
        }

        repeat(18) { index ->
            val x = ((index * 53f) % size.width)
            val y = ((progress * size.height * 1.15f + index * 83f) % size.height)
            drawLine(
                color = colors[index % colors.size].copy(alpha = 0.72f),
                start = Offset(x, y),
                end = Offset(x + if (index % 2 == 0) 8f else -8f, y + 13f),
                strokeWidth = 5f,
                cap = StrokeCap.Round
            )
        }
    }
}

@Composable
private fun GameTutorialOverlay(onDismiss: () -> Unit) {
    val transition = rememberInfiniteTransition(label = "slide_demo")
    val slideProgress by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1_250),
            repeatMode = RepeatMode.Reverse
        ),
        label = "demo_tile_slide"
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(PremiumBackgroundDark.copy(alpha = 0.82f))
            .clickable(enabled = true, onClick = {}),
        contentAlignment = Alignment.Center
    ) {
        PremiumPanel(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 26.dp),
            shape = RoundedCornerShape(28.dp)
        ) {
            Column(
                modifier = Modifier
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 22.dp, vertical = 22.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "HOW TO PLAY",
                    color = PremiumGold,
                    fontSize = 13.sp,
                    letterSpacing = 2.sp,
                    fontWeight = FontWeight.Black
                )
                Text(
                    text = "Slide the picture tiles",
                    color = PremiumTextWhite,
                    fontSize = 25.sp,
                    fontWeight = FontWeight.Black,
                    textAlign = TextAlign.Center
                )
                Text(
                    text = "Move adjacent pieces into the empty space.",
                    color = PremiumTextGray,
                    fontSize = 14.sp,
                    textAlign = TextAlign.Center
                )

                Spacer(Modifier.height(18.dp))
                TutorialBoard(slideProgress)

                Spacer(Modifier.height(14.dp))
                TutorialTip("1", "Find the empty dark square")
                TutorialTip("2", "Tap or swipe a neighboring tile")
                TutorialTip("3", "Complete the picture to unlock the next puzzle")
                Spacer(Modifier.height(18.dp))
                PremiumGameButton(
                    text = "GOT IT",
                    onClick = onDismiss,
                    icon = GameIcon.Check,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    primaryColor = PremiumGoldLight,
                    secondaryColor = PremiumGold,
                    textColor = PremiumTextDark
                )
            }
        }
    }
}

@Composable
private fun TutorialBoard(slideProgress: Float) {
    Canvas(Modifier.size(225.dp)) {
        val gap = 7f
        val tile = (size.width - gap * 4f) / 3f
        val colors = listOf(
            PremiumPrimaryLight,
            PremiumAccent,
            PremiumGold,
            Color(0xFF5DADEC),
            PremiumSuccess,
            PremiumPrimary,
            PremiumWarning,
            Color(0xFFFF9A64)
        )

        drawRoundRect(
            color = PremiumSurfaceHighlight,
            cornerRadius = CornerRadius(20f, 20f),
            size = size
        )
        drawRoundRect(
            color = PremiumStroke,
            cornerRadius = CornerRadius(20f, 20f),
            size = size,
            style = Stroke(width = 3f)
        )

        drawRoundRect(
            color = PremiumBackgroundDark.copy(alpha = 0.72f),
            topLeft = Offset(gap + 2f * (tile + gap), gap + 2f * (tile + gap)),
            size = Size(tile, tile),
            cornerRadius = CornerRadius(12f, 12f)
        )

        var colorIndex = 0
        repeat(9) { position ->
            if (position == 7 || position == 8) return@repeat
            val row = position / 3
            val column = position % 3
            drawRoundRect(
                color = colors[colorIndex++ % colors.size],
                topLeft = Offset(gap + column * (tile + gap), gap + row * (tile + gap)),
                size = Size(tile, tile),
                cornerRadius = CornerRadius(12f, 12f)
            )
        }

        val movingX = gap + (1f + slideProgress) * (tile + gap)
        val movingY = gap + 2f * (tile + gap)
        drawRoundRect(
            color = Color.Black.copy(alpha = 0.20f),
            topLeft = Offset(movingX, movingY + 6f),
            size = Size(tile, tile),
            cornerRadius = CornerRadius(12f, 12f)
        )
        drawRoundRect(
            color = PremiumGold,
            topLeft = Offset(movingX, movingY),
            size = Size(tile, tile),
            cornerRadius = CornerRadius(12f, 12f)
        )
        drawLine(
            color = PremiumTextDark,
            start = Offset(gap + 1.48f * (tile + gap), movingY - 10f),
            end = Offset(gap + 2.50f * (tile + gap), movingY - 10f),
            strokeWidth = 5f,
            cap = StrokeCap.Round
        )
    }
}

@Composable
private fun TutorialTip(number: String, text: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 3.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(27.dp)
                .clip(CircleShape)
                .background(PremiumGold),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = number,
                color = PremiumTextDark,
                fontWeight = FontWeight.Black,
                fontSize = 13.sp
            )
        }
        Spacer(Modifier.size(10.dp))
        Text(
            text = text,
            color = PremiumTextGray,
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold
        )
    }
}

@Composable
private fun PrivacyPolicyDialog(content: String?, onDismiss: () -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        containerColor = PremiumBackgroundDark,
        shape = RoundedCornerShape(24.dp),
        title = {
            Text(
                text = "Privacy Policy",
                color = PremiumTextWhite,
                fontWeight = FontWeight.Black
            )
        },
        text = {
            if (content == null) {
                Box(Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = PremiumPrimaryLight)
                }
            } else {
                Text(
                    text = content,
                    color = PremiumTextGray,
                    modifier = Modifier.verticalScroll(rememberScrollState())
                )
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Close", color = PremiumAccent, fontWeight = FontWeight.Bold)
            }
        }
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

private fun shareCompletion(context: Context, level: Int, result: CompletionUi) {
    val text = "I completed Image Puzzle Level $level in ${result.moves} moves and ${formatTime(result.seconds)}."
    runCatching {
        context.startActivity(
            Intent.createChooser(
                Intent(Intent.ACTION_SEND).apply {
                    type = "text/plain"
                    putExtra(Intent.EXTRA_TEXT, text)
                },
                "Share puzzle result"
            )
        )
    }
}
