import SwiftUI

struct EmptyStateView: View {
    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Illustration area
            ZStack {
                // Outer pulse ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.mint.opacity(0.3), Color.teal.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(pulseScale)
                    .opacity(isAnimating ? 0 : 0.8)

                // Mid ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.teal.opacity(0.12),
                                Color.mint.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 70
                        )
                    )
                    .frame(width: 130, height: 130)

                // Icon container
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white,
                                    Color(white: 0.96)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)
                        .shadow(color: Color.teal.opacity(0.2), radius: 20, x: 0, y: 8)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                    Image(systemName: "checklist.checked")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.teal, Color.mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .offset(y: floatOffset)
            }
            .padding(.bottom, 36)

            // Text content
            VStack(spacing: 10) {
                Text("You're all caught up")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)

                Text("Your task list is empty.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
            }

            Spacer()

            // Subtle hint pill
            HStack(spacing: 6) {
                Image(systemName: "arrowshape.down.circle.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.teal)
                Text("Add your first task")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.teal)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(Color.teal.opacity(0.1))
            )
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            // Floating animation
            withAnimation(
                .easeInOut(duration: 2.4)
                .repeatForever(autoreverses: true)
            ) {
                floatOffset = -8
            }

            // Pulse ring animation
            withAnimation(
                .easeOut(duration: 1.8)
                .repeatForever(autoreverses: false)
            ) {
                pulseScale = 1.4
                isAnimating = true
            }
        }
    }
}

