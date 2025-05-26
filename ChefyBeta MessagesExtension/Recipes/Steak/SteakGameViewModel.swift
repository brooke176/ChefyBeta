import SwiftUI
import Foundation

// Enums SteakSide, GameScoreMetric, and GameStage are now defined in Models.swift
// and are used directly by this ViewModel.

class SteakGameViewModel: ObservableObject {
    // Constants
    let PERFECT_SEAR_WINDOW_START = 0.4
    let PERFECT_SEAR_WINDOW_END = 0.6
    let STIR_INTERVAL_THRESHOLD: TimeInterval = 5.0 // seconds
    let MAX_ALLOWED_BURN_LEVEL = 0.8
    let PERFECT_MUSHROOM_WINDOW_START = 0.5
    let PERFECT_MUSHROOM_WINDOW_END = 0.7
    let PERFECT_WELLINGTON_WINDOW_START = 0.6
    let PERFECT_WELLINGTON_WINDOW_END = 0.8
    let NUM_SEASONING_ZONES = 3

    @Published var gameState: GameState
    @Published var seasoning = SteakSeasoning()

    // Steak Seasoning
    @Published var seasoningCorrectness: [SteakSide: [Bool]] = [
        .front: Array(repeating: false, count: 3), // Assuming NUM_SEASONING_ZONES will be used here upon init
        .back: Array(repeating: false, count: 3)
    ]

    // Steak Searing
    @Published var cookingProgress = 0.0 // Existing, will be reused for searing stage
    @Published var isCooking = false // Existing, will be reused for searing stage
    @Published var steakFlipped = true // Existing, true initially means front side is up
    @Published var searQuality: GameScoreMetric = .poor
    @Published var flipNeeded: Bool = false
    @Published var steakSearTimeInTargetWindow: Bool = false

    // Mushroom Sauté
    @Published var mushroomCookingProgress = 0.0 // Existing
    @Published var isMushroomsCooking = false // Existing
    @Published var mushroomStirred = false // Existing, might be redundant if we use timeSinceLastStir for logic
    @Published var rotationDegrees = 0 // Existing, for UI
    @Published var mushroomColor: Color = Color.brown // Existing, UI representation of burn
    @Published var timeSinceLastStir: TimeInterval = 0
    @Published var mushroomBurnLevel: Double = 0.0 // 0.0 to 1.0
    @Published var mushroomsCookedInTargetWindow: Bool = false

    // Pastry Rolling
    @Published var pastryRollingFailedTimer: Bool = false

    // Pastry Prep
    @Published var mushroomsSpread = false // Existing
    @Published var mushroomSpreadCoveragePercent: Double = 0.0 // 0.0 to 1.0

    // Wellington Oven Cooking
    @Published var isWellingtonCooking = false // Existing
    @Published var wellingtonCookingProgress = 0.0 // Existing
    @Published var wellingtonCookedInTargetWindow: Bool = false
    
    // Shared variables
    @Published var gameEnded = false
    @Published var mistakesMadeThisStage: Int = 0
    @Published var gameMessage = ""
    @Published var showingLoadingOverlay = false // Consider if this is still needed with stage transitions
    @Published var showCookingView = false // These showXView booleans might be replaced by currentStage logic
    @Published var showMushroomView = false
    @Published var showDoughRollingView = false
    @Published var showDoughPrepView = false
    @Published var showOvenCookingView = false

    var timer: Timer?
    var seasoningGraphics: [SeasoningGraphic] = [] // Keep for visual effect if needed
    var messagesViewController: MessagesViewController
    var onRequestCompactMode: (() -> Void)?
    private var conversationManager: ConversationManager?
    @Published var currentStage: GameStage? = .seasonSteak // Start at seasoning by default

    // Original seasoning constants - will be used per zone or re-evaluated.
    let minSeasoningAmount: Double = 0.6 // This will now be per zone
    let maxSeasoningAmount = 3.0    // This will now be per zone
    let perfectSeasoningRange = 0.6...1.5 // This will now be per zone

    let maxCookingProgress = 1.0 // General max progress for timer-based stages
    // let minCookingProgress = 0.0 // Redundant, progress starts at 0
    // let minCookingProg = 0.0 // Redundant

    init(gameState: GameState, messagesViewController: MessagesViewController) {
        self.gameState = gameState
        self.messagesViewController = messagesViewController
        // Initialize seasoningCorrectness with the correct number of zones
        self.seasoningCorrectness = [
            .front: Array(repeating: false, count: NUM_SEASONING_ZONES),
            .back: Array(repeating: false, count: NUM_SEASONING_ZONES)
        ]
        // Set currentStage based on gameState if resuming a game
        // For now, starting new game implies .seasonSteak
    }

    // ---MODIFIED FUNCTIONS---
    func addSeasoningGraphics(type: SeasoningType, zoneIndex: Int? = nil) { // Added zoneIndex, though UI part is TBD
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let addAmount: Double = 0.1 * 5 // Original amount, might need fine-tuning for zones
        
        // Determine current side based on steakFlipped state
        // Note: Original logic had `!steakFlipped ? .back : .front`.
        // Assuming steakFlipped = true means front is UP, so seasoning applies to front.
        // If steakFlipped = false means back is UP (after a flip), seasoning applies to back.
        let currentSide: SteakSide = steakFlipped ? .front : .back

        // Update the global seasoning amount for the side.
        // This is a simplification: ideally, we'd have per-zone amounts in SteakSeasoning struct.
        // For now, frontSalt/Pepper applies to all zones on the front, and we check that average.
        switch type {
        case .salt:
            if currentSide == .front {
                seasoning.frontSalt = min(seasoning.frontSalt + addAmount, maxSeasoningAmount * Double(NUM_SEASONING_ZONES))
            } else {
                seasoning.backSalt = min(seasoning.backSalt + addAmount, maxSeasoningAmount * Double(NUM_SEASONING_ZONES))
            }
        case .pepper:
            if currentSide == .front {
                seasoning.frontPepper = min(seasoning.frontPepper + addAmount, maxSeasoningAmount * Double(NUM_SEASONING_ZONES))
            } else {
                seasoning.backPepper = min(seasoning.backPepper + addAmount, maxSeasoningAmount * Double(NUM_SEASONING_ZONES))
            }
        }

        // Update seasoningCorrectness for all zones on the current side.
        // This is a simplification. Ideally, UI tells us which zone was tapped.
        // If zoneIndex is nil, apply to all zones on the side. If provided, only that zone.
        let zonesToUpdate = zoneIndex != nil ? [zoneIndex!] : Array(0..<NUM_SEASONING_ZONES)

        for i in zonesToUpdate {
            guard i < NUM_SEASONING_ZONES else { continue } // Boundary check

            // Calculate average seasoning amount for the purpose of checking correctness.
            // This assumes frontSalt/Pepper is total for the side.
            let saltForSide = (currentSide == .front) ? seasoning.frontSalt : seasoning.backSalt
            let pepperForSide = (currentSide == .front) ? seasoning.frontPepper : seasoning.backPepper
            
            // For a zone to be correct, BOTH salt and pepper on that side must be in range.
            // We're simplifying that each zone gets an "average" amount of the total seasoning applied to the side.
            let averageSaltPerZone = saltForSide / Double(NUM_SEASONING_ZONES)
            let averagePepperPerZone = pepperForSide / Double(NUM_SEASONING_ZONES)

            let saltInPerfectRange = perfectSeasoningRange.contains(averageSaltPerZone)
            let pepperInPerfectRange = perfectSeasoningRange.contains(averagePepperPerZone)

            if saltInPerfectRange && pepperInPerfectRange {
                seasoningCorrectness[currentSide]?[i] = true
            } else if averageSaltPerZone > maxSeasoningAmount * 1.1 || averagePepperPerZone > maxSeasoningAmount * 1.1 { // Over-seasoned check
                seasoningCorrectness[currentSide]?[i] = false
                mistakesMadeThisStage += 1
            } else { // Under-seasoned or otherwise not perfect
                seasoningCorrectness[currentSide]?[i] = false
            }
        }

        // Visual graphics (original logic, but using currentSide)
        let seasoningColor = type == .salt ? Color.white : Color.black
        for _ in 1...5 { // Add 5 particles for visual feedback
            let newPosition = CGPoint(x: CGFloat.random(in: 180...280), y: CGFloat.random(in: 250...300))
            seasoningGraphics.append(SeasoningGraphic(position: newPosition, color: seasoningColor, type: type, side: currentSide))
        }
    }
    
    func flipSteak() {
        steakFlipped.toggle()
        flipNeeded = false // Reset flip needed status after flipping
        // TODO: Add logic if steak was flipped too late/early based on cookingProgress, affecting searQuality
    }

    // ---Steak Searing Logic---
    // startCooking() is now specifically for searing steak
    // Original startCooking() becomes startSearingSteak() or similar if needed, but for now, modify existing.
    // func startCooking() from original is modified:

    // func startCookingWellington() from original is modified:
    func startCookingWellington() {
        currentStage = .cookWelly // Ensure stage is set
        isWellingtonCooking = true
        showOvenCookingView = true // UI flag
        wellingtonCookingProgress = 0.0
        wellingtonCookedInTargetWindow = false // Reset for this cooking session
        mistakesMadeThisStage = 0 // Reset for this stage
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.wellingtonCookingProgress += 0.1 // Increment progress

            // Check if cooking is complete
            if self.wellingtonCookingProgress >= self.maxCookingProgress {
                self.endCookingWellington() // Automatically end or player action
            }
        }
    }

    // func startCookingMushrooms() from original is modified:
    func startCookingMushrooms() {
        currentStage = .sauteMushrooms
        isMushroomsCooking = true
        showMushroomView = true // UI flag
        mushroomCookingProgress = 0.0
        timeSinceLastStir = 0
        mushroomBurnLevel = 0.0
        mushroomsCookedInTargetWindow = false
        mushroomColor = Color.brown // Reset color
        mistakesMadeThisStage = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.mushroomCookingProgress += 0.1
            self.timeSinceLastStir += 1.0

            if self.timeSinceLastStir > self.STIR_INTERVAL_THRESHOLD {
                self.mushroomBurnLevel = min(1.0, self.mushroomBurnLevel + 0.15) // Increase burn level faster
                self.mistakesMadeThisStage += 1 // Penalty for not stirring
                self.updateMushroomVisuals() // Update color based on burn
            }
            
            if self.mushroomBurnLevel >= self.MAX_ALLOWED_BURN_LEVEL {
                 // Mushrooms might be too burnt, consider auto-ending or severe penalty
                 // self.endCookingMushrooms(failedDueToBurn: true)
            }
            
            if self.mushroomCookingProgress >= self.maxCookingProgress {
                self.endCookingMushrooms() // Auto-end or player action
            }
        }
    }

    // func stirMushrooms() from original is modified:
    func stirMushrooms() {
        guard isMushroomsCooking else { return }
        timeSinceLastStir = 0
        // Slightly decrease burn level if not too high, as a reward for stirring
        if mushroomBurnLevel > 0 && mushroomBurnLevel < MAX_ALLOWED_BURN_LEVEL * 0.75 { // Allow reduction if not too burnt
            mushroomBurnLevel = max(0, mushroomBurnLevel - 0.05)
        }
        mushroomStirred = true // For UI indication if needed (can be removed if not used)
        rotationDegrees += 45 // For UI
        updateMushroomVisuals() // Update color based on new burn level
    }
    
    // New helper for mushroom visuals
    func updateMushroomVisuals() {
        // Example: Darken color based on burn level
        let baseBrown = UIColor.brown
        let blendedColor = baseBrown.blendWithColor(UIColor.black, alpha: CGFloat(mushroomBurnLevel))
        mushroomColor = Color(blendedColor)
        
        // Potentially also change shape or add smoke particles for high burn levels via other @Published vars
    }


    func endCookingMushrooms(failedDueToBurn: Bool = false) {
        isMushroomsCooking = false
        timer?.invalidate()

        if !failedDueToBurn {
            if mushroomCookingProgress >= PERFECT_MUSHROOM_WINDOW_START && mushroomCookingProgress <= PERFECT_MUSHROOM_WINDOW_END {
                mushroomsCookedInTargetWindow = true
            }
            // If not in window, it's false by default, score will reflect this.
        } else {
            mushroomsCookedInTargetWindow = false // Failed, so not in target window
            // Score calculation will heavily penalize based on high burn level.
        }
        
        // Transition to next stage
        currentStage = .rollDough // As per game flow
        showDoughRollingView = true // UI flag
        resetMushroomCookingVariables() // Reset for this specific stage
    }
    
    // func startCooking() from original, now repurposed for searing steak:
    func startCooking() { // This is now for SEARING STEAK
        currentStage = .searSteak
        isCooking = true // General flag for active cooking timer
        showCookingView = true // UI flag for searing view
        
        cookingProgress = 0.0 // Steak searing progress
        searQuality = .poor // Initial quality
        flipNeeded = false
        steakSearTimeInTargetWindow = false
        mistakesMadeThisStage = 0
        
        timer?.invalidate() // Ensure no other timer is running
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.cookingProgress += 0.01 // Finer grain progress for searing

            self.updateSearQualityAndFlipStatus() // Manage flipNeeded and quality degradation

            // Searing stage doesn't auto-end with cookingProgress. Player decides when to "Serve Steak".
            // However, if it goes on for too long, it might auto-fail or quality drops to very poor.
            if self.cookingProgress >= (self.maxCookingProgress * 1.5) { // Example: 50% over max time
                // self.serveSteak() // Force end stage, quality will be poor
            }
        }
    }
    
    // New helper function as requested
    func updateSearQualityAndFlipStatus() {
        let currentSideCookTime = steakFlipped ? (cookingProgress - (gameState.lastFlipTime ?? 0)) : cookingProgress
        // Example: Flip needed after 0.2 progress on current side (e.g. 2 seconds if 0.01 is 0.1s)
        let flipThreshold = 0.2 // Arbitrary threshold for needing a flip

        if !flipNeeded && currentSideCookTime > flipThreshold {
            flipNeeded = true
        }

        // Degrade quality if not flipped on time (simplified)
        // Example: if flip was needed at `flipThreshold` and current side cook time is `flipThreshold + 0.1`
        if flipNeeded && currentSideCookTime > (flipThreshold + 0.1) {
            if searQuality == .good { searQuality = .okay }
            else if searQuality == .okay { searQuality = .poor }
            mistakesMadeThisStage += 1 // Or a more direct penalty to searQuality
            // This is a simple degradation. Could be more nuanced.
        }
    }


    // func endCookingWellington() from original is modified:
    func endCookingWellington() {
        isWellingtonCooking = false
        timer?.invalidate()
        
        // Determine if cooked in target window before calculating score
        if wellingtonCookingProgress >= PERFECT_WELLINGTON_WINDOW_START && wellingtonCookingProgress <= PERFECT_WELLINGTON_WINDOW_END {
            wellingtonCookedInTargetWindow = true
        } else {
            wellingtonCookedInTargetWindow = false
            // Implicitly, if not in window, quality is lower, affecting score.
            // Could also increment mistakesMadeThisStage here if desired.
        }

        showingLoadingOverlay = true // Keep for transition if necessary

        let score = calculateScore() // New calculateScore will use new state vars

        // Update gameState (original logic seems fine)
        if gameState.currentPlayer == "player1" {
            gameState.player1Score = score
            gameState.player1Played = true
            gameState.currentPlayer = "player2"
        } else if gameState.currentPlayer == "player2" {
            gameState.player2Score = score
            gameState.player2Played = true
            // currentPlayer could go to "player1" or a "gameOver" state if both played
        }

        messagesViewController.gameState = gameState
        messagesViewController.updateAndSendGameState { [weak self] in
            DispatchQueue.main.async {
                self?.checkGameEnd() // Determines if game is over or next player's turn
                                     // resetGame() should be called conditionally by checkGameEnd or after outcome
                // self?.resetGame() // Reset for the *next* player or a new game, not before outcome.
                self?.currentStage = .outcome // Show results of this turn/game
                self?.onRequestCompactMode?()
            }
        }
    }

    // func finishRollingDough() from original:
    func finishRollingDough() { // Called when player submits rolling
        // Logic for checking if rolling was successful based on UI interaction would go here.
        // For now, just transition. PastryRollingView should set pastryRollingFailedTimer.
        // If pastryRollingFailedTimer is true by the time calculateScore() is called, it will be factored in.
        currentStage = .prepPastry
        showDoughPrepView = true // UI flag
    }
    
    // New: finishPastryPrep (similar to finishRollingDough, for stage transition)
    func finishPastryPrep() { // Called when player finishes spreading mushrooms on pastry
        // UI should update mushroomSpreadCoveragePercent.
        // Logic for spread quality could be here if needed, or just use the percent in scoring.
        currentStage = .cookWelly
        showOvenCookingView = true
        // startCookingWellington() is called from UI or automatically after this.
    }


    // func resetMushroomCookingVariables() from original:
    func resetMushroomCookingVariables() { // Renamed for clarity if needed, but it's specific enough
        mushroomCookingProgress = 0.0
        isMushroomsCooking = false
        mushroomStirred = false // Reset this, though timeSinceLastStir is main logic driver
        timeSinceLastStir = 0
        mushroomBurnLevel = 0.0 // Reset for next round
        rotationDegrees = 0
        mushroomColor = Color.brown // Reset visual state
    }
    
    private func resetSteakSearingVariables() {
        cookingProgress = 0.0 // This is steak searing progress
        isCooking = false
        // steakFlipped = true // Reset to front side up for next player/game.
        flipNeeded = false
        searQuality = .poor
        steakSearTimeInTargetWindow = false
        // seasoningGraphics.removeAll() // If seasoning is per game turn, clear them.
                                      // If seasoning is for the whole steak object that persists, don't.
                                      // Based on current structure, seems like per game turn.
    }


    // func serveSteak() from original is modified:
    func serveSteak() { // Called when player decides searing is done for the steak
        isCooking = false // Stop searing timer
        timer?.invalidate()
        
        // Determine searQuality and if it was in the target window
        if cookingProgress >= PERFECT_SEAR_WINDOW_START && cookingProgress <= PERFECT_SEAR_WINDOW_END {
            steakSearTimeInTargetWindow = true
            // Further refine searQuality based on flip status etc.
            // If flipNeeded is false here, it implies it was flipped.
            // This is a simplification. A more robust check would be to see if gameState.lastFlipTime exists and was appropriate.
            if !flipNeeded { // Simplified: assumes flip happened correctly if served in window and flip is no longer needed
                 searQuality = .good
            } else { // Not flipped or other issues
                 searQuality = .okay
                 mistakesMadeThisStage += 1 // Penalty for not flipping or flipping badly
            }
        } else if cookingProgress < PERFECT_SEAR_WINDOW_START {
            searQuality = .poor // Undercooked
            mistakesMadeThisStage += 1
        } else { // Overcooked
            searQuality = .okay // Or .poor if severely overcooked
            mistakesMadeThisStage += 1
        }
        
        // Transition to next stage
        currentStage = .sauteMushrooms
        showMushroomView = true // UI flag
        // Don't reset all steak variables here, only those specific to the searing timer process.
        // resetSteakSearingVariables() // Call this if these vars should not persist to score calculation.
                                     // Or, ensure score calculation uses copies/snapshots.
                                     // For now, the properties will hold their values until resetGame().
    }

    // calculateScore() is completely new based on requirements
    private func calculateScore() -> Int {
        var totalScore = 0
        let MAX_POINTS_PER_CATEGORY = 20 // Example: 20 points for each of 5 categories = 100 total

        // 1. Seasoning Score (Max 20 points)
        var seasoningPoints = 0
        for side in [SteakSide.front, SteakSide.back] {
            guard let sideCorrectness = seasoningCorrectness[side] else { continue }
            let pointsPerZone = (MAX_POINTS_PER_CATEGORY / 2) / NUM_SEASONING_ZONES // e.g., 10 points per side / 3 zones
            for zoneCorrect in sideCorrectness {
                if zoneCorrect {
                    seasoningPoints += pointsPerZone
                }
            }
        }
        totalScore += seasoningPoints

        // 2. Searing Score (Max 20 points)
        var searingPoints = 0
        switch searQuality {
        case .poor: searingPoints = MAX_POINTS_PER_CATEGORY / 4 // 5 pts
        case .okay: searingPoints = MAX_POINTS_PER_CATEGORY / 2 // 10 pts
        case .good: searingPoints = (MAX_POINTS_PER_CATEGORY * 3) / 4 // 15 pts
        case .perfect: searingPoints = MAX_POINTS_PER_CATEGORY // 20 pts (Perfect might be hard to achieve without more states)
        }
        if steakSearTimeInTargetWindow { // Bonus for timing if quality is at least okay
            if searQuality != .poor { searingPoints += MAX_POINTS_PER_CATEGORY / 5 } // Bonus 4 pts
        }
        totalScore += min(searingPoints, MAX_POINTS_PER_CATEGORY) // Cap at max

        // 3. Mushroom Score (Max 20 points)
        var mushroomPoints = 0
        if mushroomsCookedInTargetWindow {
            mushroomPoints += MAX_POINTS_PER_CATEGORY / 2 // Base 10 points for good timing
        }
        // Deduct points based on burn level (e.g., 1 point per 0.05 burnLevel over a threshold)
        let burnPenaltyThreshold = 0.1 // No penalty if burn is very low
        if mushroomBurnLevel > burnPenaltyThreshold {
            let excessBurn = mushroomBurnLevel - burnPenaltyThreshold
            let penalty = Int(excessBurn * 100) // Example: 0.1 excess burn = 10 points penalty
            mushroomPoints -= penalty
        }
        if mushroomBurnLevel < burnPenaltyThreshold && mushroomsCookedInTargetWindow { // Low burn and good timing = perfect mushrooms
             mushroomPoints = MAX_POINTS_PER_CATEGORY // Max points for good mushrooms
        }
        totalScore += max(0, mushroomPoints) // Ensure not negative, cap at MAX_POINTS_PER_CATEGORY if needed
        
        // 4. Pastry Rolling Score (Max 20 points)
        var pastryPoints = MAX_POINTS_PER_CATEGORY
        if pastryRollingFailedTimer { // This flag is set by UI interaction if timer expires
            pastryPoints = MAX_POINTS_PER_CATEGORY / 4 // Heavy penalty: 5 pts
        }
        totalScore += pastryPoints
        
        // 5. Mushroom Spread Score (Max 20 points)
        // mushroomSpreadCoveragePercent is set by UI based on drawing
        let spreadPoints = Int(mushroomSpreadCoveragePercent * Double(MAX_POINTS_PER_CATEGORY))
        totalScore += spreadPoints
        
        // 6. Wellington Bake Score (Max 20 points)
        var wellingtonPoints = 0
        if wellingtonCookedInTargetWindow {
            wellingtonPoints = MAX_POINTS_PER_CATEGORY // 20 pts for perfect bake time
        } else {
            // Scaled points based on how far from target window
            if wellingtonCookingProgress < PERFECT_WELLINGTON_WINDOW_START { // Undercooked
                 wellingtonPoints = MAX_POINTS_PER_CATEGORY / 3 // ~6 pts
            } else { // Overcooked (progress > PERFECT_WELLINGTON_WINDOW_END)
                 wellingtonPoints = MAX_POINTS_PER_CATEGORY / 2 // 10 pts
            }
        }
        totalScore += wellingtonPoints
        
        // Deduct for mistakes made across stages, if this var is used globally.
        // For now, mistakesMadeThisStage is reset per stage and penalties applied within category.
        // totalScore -= (totalMistakesOverall * somePenaltyFactor)

        NSLog("Final Score: \(totalScore) ---- Seasoning: \(seasoningPoints), Searing: \(searingPoints), Mushrooms: \(mushroomPoints), Pastry: \(pastryPoints), Spread: \(spreadPoints), Wellington: \(wellingtonPoints)")
        return totalScore // Max possible could be 120 based on this example. Adjust as needed.
    }

    // func resetGame() from original is modified:
     func resetGame() { // Resets for a new game or next player's turn
        // Seasoning
        seasoning = SteakSeasoning() // Reset amounts (frontSalt, etc.)
        seasoningCorrectness = [.front: Array(repeating: false, count: NUM_SEASONING_ZONES), .back: Array(repeating: false, count: NUM_SEASONING_ZONES)]
        seasoningGraphics.removeAll() // Clear visual particles

        // Searing
        resetSteakSearingVariables() // Resets its specific variables
        
        // Mushrooms
        resetMushroomCookingVariables() // Resets its specific variables
        
        // Pastry Rolling
        pastryRollingFailedTimer = false
        
        // Pastry Prep
        mushroomsSpread = false // This is an old variable, coverage percent is new
        mushroomSpreadCoveragePercent = 0.0
        
        // Wellington Cooking
        wellingtonCookingProgress = 0.0
        isWellingtonCooking = false
        wellingtonCookedInTargetWindow = false
        
        // General game state variables
        // gameEnded should be managed by checkGameEnd logic.
        // If resetGame is called for a new player in the same game, gameEnded might be false.
        // If it's for a brand new game instance, then it's fine.
        // mistakesMadeThisStage is reset at the start of each stage, so not needed here.
        
        // currentStage should be reset to the beginning for the next player/game
        currentStage = .seasonSteak 

        // GameState scores (player1Score, player2Score, playerXPlayed) are NOT reset here.
        // They are managed by the overall game flow (e.g., starting a new iMessage game, or `checkGameEnd` logic).
        // Showing loading overlay should also be managed by specific transitions, not globally reset here.
        // showingLoadingOverlay = false
    }

    // func checkGameEnd() from original:
    func checkGameEnd() {
        if gameState.player1Played && gameState.player2Played {
            gameEnded = true // Both players have played
            gameMessage = determineWinner()
            // At this point, the game instance is complete.
            // `resetGame()` might be called after this if the user chooses to play a new game.
        } else {
            // Game is not over yet, one player might have played.
            gameEnded = false
            // If player 1 just finished, it's player 2's turn. ViewModel should be reset for P2.
            if gameState.player1Played && !gameState.player2Played && gameState.currentPlayer == "player2" {
                resetGame() // Reset the board for player 2
                // UI should reflect it's Player 2's turn.
            }
            // Similar logic if roles were reversed, though current structure implies P1 then P2.
        }
    }

    // func determineWinner() from original:
     func determineWinner() -> String {
        if gameState.player1Score > gameState.player2Score {
            return "Player 1 wins with a score of \(gameState.player1Score)!"
        } else if gameState.player2Score > gameState.player1Score { // Original had a bug here: gameState.player2Score > gameState.player2Score
            return "Player 2 wins with a score of \(gameState.player2Score)!"
        } else {
            return "It's a tie! Both scored \(gameState.player1Score)."
        }
    }
}

// Extension for UIColor blending (used for mushroom burn color)
// Keep this if not available elsewhere, or move to a general utilities file.
extension UIColor {
    func blendWithColor(_ color: UIColor, alpha: CGFloat) -> UIColor {
        let alphaClamped = min(max(alpha, 0), 1) // Ensure alpha is between 0 and 1
        let beta = 1 - alphaClamped
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let r = r1 * beta + r2 * alphaClamped
        let g = g1 * beta + g2 * alphaClamped
        let b = b1 * beta + b2 * alphaClamped
        
        return UIColor(red: r, green: g, blue: b, alpha: 1) // Resulting color is opaque
    }
}
