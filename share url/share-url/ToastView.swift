import SwiftUI

enum ToastStyle {
    case success
    case error
    case warning
    case info
    
    var icon: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success:
            return .green
        case .error:
            return .red
        case .warning:
            return .orange
        case .info:
            return .blue
        }
    }
}

struct ToastView: View {
    let message: String
    let style: ToastStyle
    let duration: Double
    let completion: () -> Void
    
    @State private var isShowing = false
    
    init(
        message: String,
        style: ToastStyle = .info,
        duration: Double = 2.0,
        completion: @escaping () -> Void = {}
    ) {
        self.message = message
        self.style = style
        self.duration = duration
        self.completion = completion
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: style.icon)
                .foregroundColor(style.color)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeOut(duration: 0.2)) {
                    isShowing = false
                    completion()
                }
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .opacity(isShowing ? 1 : 0)
        .offset(y: isShowing ? 0 : -20)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isShowing)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                isShowing = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.easeIn(duration: 0.2)) {
                    isShowing = false
                    completion()
                }
            }
        }
    }
}

// Toast modifier for easier usage throughout the app
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let style: ToastStyle
    let duration: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    ToastView(
                        message: message,
                        style: style,
                        duration: duration,
                        completion: {
                            isShowing = false
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                }
                .animation(.easeInOut, value: isShowing)
            }
        }
    }
}

// Extension to use toast as a view modifier
extension View {
    func toast(
        isShowing: Binding<Bool>,
        message: String,
        style: ToastStyle = .info,
        duration: Double = 2.0
    ) -> some View {
        self.modifier(
            ToastModifier(
                isShowing: isShowing,
                message: message,
                style: style,
                duration: duration
            )
        )
    }
}

// Usage example as a view
struct ToastViewDemo: View {
    @State private var showSuccessToast = false
    @State private var showErrorToast = false
    @State private var showInfoToast = false
    @State private var showWarningToast = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Toast Examples")
                .font(.title)
            
            Button("Show Success Toast") {
                showSuccessToast = true
            }
            .buttonStyle(.bordered)
            
            Button("Show Error Toast") {
                showErrorToast = true
            }
            .buttonStyle(.bordered)
            
            Button("Show Info Toast") {
                showInfoToast = true
            }
            .buttonStyle(.bordered)
            
            Button("Show Warning Toast") {
                showWarningToast = true
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .toast(isShowing: $showSuccessToast, message: "Operation successful!", style: .success)
        .toast(isShowing: $showErrorToast, message: "An error occurred", style: .error)
        .toast(isShowing: $showInfoToast, message: "Here's some information", style: .info)
        .toast(isShowing: $showWarningToast, message: "Warning: This action cannot be undone", style: .warning)
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Individual toasts
            ToastView(message: "Success message", style: .success)
            ToastView(message: "Error message", style: .error)
            ToastView(message: "Warning message", style: .warning)
            ToastView(message: "Info message", style: .info)
            
            // Demo with buttons
            ToastViewDemo()
        }
        .padding()
    }
}
