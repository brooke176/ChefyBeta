import Foundation
import SwiftUI

// Represents a single seasoning zone on the steak.
struct ZoneView: View {
    var isWellSeasoned: Bool
    // Future enhancement: var isOverSeasoned: Bool

    var body: some View {
        Rectangle()
            .fill(zoneColor)
            .frame(width: 50, height: 30) // Adjust size as needed
            .opacity(0.4) // Semi-transparent
            .border(Color.white.opacity(0.6), width: 1) // Optional border
    }

    private var zoneColor: Color {
        if isWellSeasoned {
            return Color.green.opacity(0.5) // Greenish tint for well-seasoned
        } else {
            return Color.red.opacity(0.3) // Reddish tint for needs seasoning or over-seasoned
        }
        // Add more logic here if isOverSeasoned is implemented
    }
}


struct SteakSeasoningView: View {
    @ObservedObject var viewModel: SteakGameViewModel
    var messagesViewController: MessagesViewController

    var body: some View {
        ZStack {
            Image("seasonSteakBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                SeasoningInstructionText(viewModel: viewModel) // Pass the whole viewModel
                .padding()
                .background(Color.white.opacity(0.8))
                .foregroundColor(Color.black)
                .font(.headline)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                )
                .padding(.vertical, 5)
                Spacer()
                SteakView(viewModel: viewModel) // Pass the whole viewModel
                ActionButtonView(viewModel: viewModel)
                    .padding(.bottom, 100)
            }
        }
    }
}

struct SeasoningInstructionText: View {
    @ObservedObject var viewModel: SteakGameViewModel

    var body: some View {
        Text(instructionText)
    }

    private var instructionText: String {
        let currentSide: SteakSide = viewModel.steakFlipped ? .front : .back
        let sideName = viewModel.steakFlipped ? "front" : "back"
        
        guard let correctnessArray = viewModel.seasoningCorrectness[currentSide] else {
            return "Season the \(sideName) of the steak."
        }

        let wellSeasonedZones = correctnessArray.filter { $0 }.count
        let totalZones = viewModel.NUM_SEASONING_ZONES

        if wellSeasonedZones == totalZones {
            if currentSide == .front && viewModel.steakFlipped { // Front side done, steak is still front up
                 return "Perfectly seasoned front! Flip the steak to season the back."
            } else if currentSide == .back && !viewModel.steakFlipped { // Back side done, steak is back up
                return "Perfectly seasoned back! Ready for the next step."
            } else { // This case implies one side is done, but the steak isn't in position for the next logical action based on text.
                 // e.g. front is done, but steak is already flipped to back. Or back is done, and steak is still back up.
                 return "\(sideName.capitalized) side is perfectly seasoned. Proceed when ready."
            }
        } else if viewModel.mistakesMadeThisStage > 0 && correctnessArray.allSatisfy({ !$0 }) {
             // This assumes if mistakes were made and all zones are currently false, it implies overseasoning.
             // ViewModel needs a more direct way to indicate "overseasoned" per zone or side for better text.
             return "Too much seasoning on the \(sideName)! Try to be more careful."
        } else if wellSeasonedZones > 0 {
            return "Some zones on the \(sideName) are good, keep seasoning the rest."
        } else {
            return "Season the \(sideName) of the steak."
        }
    }
}

struct SteakView: View {
    @ObservedObject var viewModel: SteakGameViewModel

    var body: some View {
        let currentSide: SteakSide = viewModel.steakFlipped ? .front : .back
        let zonesForCurrentSide = viewModel.seasoningCorrectness[currentSide] ?? Array(repeating: false, count: viewModel.NUM_SEASONING_ZONES)

        ZStack(alignment: .center) {
            Image("steakie")
                .resizable()
                .scaledToFit()
                .frame(width: 175, height: 175)
                // Adjust positioning to be more central if needed, original offset might be too specific
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 150) // Centered with an offset y
                .rotation3DEffect(.degrees(viewModel.steakFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .animation(.easeInOut(duration: 0.5), value: viewModel.steakFlipped)
                .onTapGesture {
                    viewModel.flipSteak() // Use the ViewModel's method
                }
            
            // Visual Seasoning Particles (Existing logic)
            ForEach(viewModel.seasoningGraphics.filter { $0.side == currentSide }) { graphic in
                Circle()
                    .fill(graphic.color)
                    .frame(width: 4, height: 4)
                    .position(graphic.position) // Ensure these positions are relative to the ZStack or SteakView frame
            }

            // --- Visual Seasoning Zones ---
            // These zones are for display only. Seasoning is applied by salt/pepper buttons.
            // NUM_SEASONING_ZONES is 3. We'll create 3 zones.
            // Positioning these correctly and dynamically on a rotating image is complex.
            // For now, static offsets relative to the steak image's assumed position.
            // These offsets will need careful adjustment and testing.
            
            // Zone 0 (e.g., Top part of steak)
            if zonesForCurrentSide.indices.contains(0) {
                ZoneView(isWellSeasoned: zonesForCurrentSide[0])
                    .offset(x: 0, y: -40) // Example offset
            }
            
            // Zone 1 (e.g., Middle part of steak)
            if zonesForCurrentSide.indices.contains(1) {
                ZoneView(isWellSeasoned: zonesForCurrentSide[1])
                    .offset(x: 0, y: 0) // Example offset
            }
            
            // Zone 2 (e.g., Bottom part of steak)
            if zonesForCurrentSide.indices.contains(2) {
                ZoneView(isWellSeasoned: zonesForCurrentSide[2])
                    .offset(x: 0, y: 40) // Example offset
            }
            
            // --- End Visual Seasoning Zones ---

            // Removed old large invisible Rectangles for salt/pepper.
            // New explicit buttons for applying seasoning will be added below the ZStack, in an HStack.
        }
        // The ZStack contains the steak and visual elements like particles and zones.
        // It's important that the SteakView ZStack has a defined frame for correct particle and zone positioning.
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2 + 50) // Adjusted frame slightly

        // Add Salt and Pepper buttons below the steak/zones display area
        HStack(spacing: 30) {
            Button(action: {
                viewModel.addSeasoningGraphics(type: .salt)
            }) {
                Text("Apply Salt")
                    .padding(10)
                    .background(Color.white.opacity(0.8))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                    .shadow(radius: 3)
            }

            Button(action: {
                viewModel.addSeasoningGraphics(type: .pepper)
            }) {
                Text("Apply Pepper")
                    .padding(10)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .shadow(radius: 3)
            }
        }
        .padding(.top, 20) // Add some padding above the buttons
    }
}

struct ActionButtonView: View {
    @ObservedObject var viewModel: SteakGameViewModel

    var body: some View {
        VStack {
            // Button action might need to check if current side is sufficiently seasoned before proceeding
            Button(action: {
                // Logic for proceeding:
                // If front is seasoned and steak is front up, flip.
                // If back is seasoned and steak is back up (or front also done), proceed to next stage.
                let currentSide: SteakSide = viewModel.steakFlipped ? .front : .back
                guard let correctnessArray = viewModel.seasoningCorrectness[currentSide],
                      correctnessArray.allSatisfy({ $0 }) else {
                    // Optionally, provide feedback that current side isn't fully seasoned.
                    // For now, button is always enabled as per original.
                    // If we want to enforce seasoning:
                    // if !correctnessArray.allSatisfy({ $0 }) { return }
                    print("Current side not fully seasoned.")
                    // For now, we allow proceeding based on original logic of the button.
                    // The user can choose to proceed even if not perfectly seasoned.
                    // Score will reflect the seasoning state.
                    
                    // Original Action:
                    viewModel.currentStage = .searSteak // <<<< CRITICAL CHANGE: Next stage is SEARING
                    viewModel.startCooking() // ViewModel's startCooking is for searing
                    // viewModel.showMushroomView = true // This was old logic. Searing comes first.
                    return
                }

                // If current side is perfectly seasoned:
                if currentSide == .front && viewModel.steakFlipped {
                    // Encourage flipping, but don't force it. Player might flip via steak tap.
                    // Or, the button itself could mean "I'm done with this side".
                    // For now, assume "Done Seasoning" means done with the ENTIRE seasoning STAGE.
                    viewModel.currentStage = .searSteak // Go to searing
                    viewModel.startCooking()
                } else if currentSide == .back && !viewModel.steakFlipped {
                    viewModel.currentStage = .searSteak // Go to searing
                    viewModel.startCooking()
                } else if viewModel.seasoningCorrectness[.front]?.allSatisfy({$0}) ?? false &&
                          viewModel.seasoningCorrectness[.back]?.allSatisfy({$0}) ?? false {
                    // Both sides are perfectly seasoned
                    viewModel.currentStage = .searSteak // Go to searing
                    viewModel.startCooking()
                } else {
                    // One side might be done, but steak not positioned optimally, or player isn't done overall.
                    // Default to proceeding to searing. Player controls flips.
                    viewModel.currentStage = .searSteak
                    viewModel.startCooking()
                }
                
            }) {
                Text("Done Seasoning, Start Searing!")
            }
            .buttonStyle(GameButtonStyle(backgroundColor: .green))
        }
    }
}

#Preview {
    SteakSeasoningView(viewModel: SteakGameViewModel(gameState: GameState(), messagesViewController: MessagesViewController()), messagesViewController: MessagesViewController())
}
