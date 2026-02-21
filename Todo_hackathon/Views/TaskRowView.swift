import SwiftUI

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    
    @State private var isAnimating = false
    
    @State private var localIsCompleted: Bool
    @State private var toggleDelayTask: _Concurrency.Task<Void, Never>? = nil
    
    init(task: Task, onToggle: @escaping () -> Void) {
        self.task = task
        self.onToggle = onToggle
        _localIsCompleted = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            toggleButton
            
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(localIsCompleted, color: .secondary)
                    .foregroundStyle(localIsCompleted ? .secondary : .primary)
                    .opacity(localIsCompleted ? 0.6 : 1.0)
                    .offset(x: localIsCompleted ? 4 : 0)
                    .scaleEffect(localIsCompleted ? 0.98 : 1.0, anchor: .leading)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: localIsCompleted)
                
                if let expirationTime = task.expirationTime {
                    HStack(spacing: 6) {
                        Image(systemName: task.isExpired ? "bell.slash.fill" : "bell.fill")
                            .imageScale(.small)
                        
                        Text(expirationTime, style: .time)
                        
                        if task.isExpired && !localIsCompleted {
                            Text("• Expired")
                                .foregroundStyle(.red)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(task.isExpired && !localIsCompleted ? .red : .secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(backgroundColor)
        .animation(.easeInOut(duration: 0.3), value: localIsCompleted)
        .cornerRadius(999)
        .contentShape(Rectangle())
        .scaleEffect(isAnimating ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isAnimating = true
            }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                localIsCompleted.toggle()
            }
            
            toggleDelayTask?.cancel()
            
            toggleDelayTask = _Concurrency.Task { @MainActor in
                try? await _Concurrency.Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                guard !_Concurrency.Task.isCancelled else { return }
                onToggle()
            }
            
            animateReset()
        }
        .onChange(of: task.isCompleted) { newValue in
            if localIsCompleted != newValue {
                localIsCompleted = newValue
            }
        }
    }
    
    private func animateReset() {
        _Concurrency.Task { @MainActor in
            try? await _Concurrency.Task.sleep(nanoseconds: 200_000_000)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isAnimating = false
            }
        }
    }
    
    private var backgroundColor: Color {
        if localIsCompleted {
            return Color.green.opacity(0.1)
        } else if task.isExpired {
            return Color.red.opacity(0.1)
        }
        return Color(.systemGray6)
    }
    
    private var toggleButton: some View {
        ZStack {
            Circle()
                .fill(localIsCompleted ? Color.green.opacity(0.15) : Color.clear)
                .frame(width: 24, height: 24)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: localIsCompleted)
            
            Circle()
                .strokeBorder(localIsCompleted ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 24, height: 24)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: localIsCompleted)
            
            if localIsCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.green)
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.1).combined(with: .opacity),
                            removal: .scale(scale: 0.1).combined(with: .opacity)
                        )
                    )
            }
        }
        .scaleEffect(localIsCompleted ? 1.08 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: localIsCompleted)
        .accessibilityLabel(localIsCompleted ? "Mark as incomplete" : "Mark as complete")
    }
}
