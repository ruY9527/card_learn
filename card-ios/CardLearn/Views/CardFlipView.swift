import SwiftUI

/// 翻转卡片组件
struct CardFlipView: View {
    let frontContent: String
    let backContent: String
    @Binding var isFlipped: Bool

    var body: some View {
        ZStack {
            // 正面
            CardFaceView(content: frontContent, isFront: true)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            // 背面
            CardFaceView(content: backContent, isFront: false)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 300)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.5)) {
                isFlipped.toggle()
            }
        }
    }
}

/// 卡片面视图
struct CardFaceView: View {
    let content: String
    let isFront: Bool

    var body: some View {
        VStack(spacing: 12) {
            // 标签
            HStack {
                Text(isFront ? "问题" : "答案")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isFront ? AppColor.info : AppColor.success)
                    .cornerRadius(10)
                Spacer()
            }

            // 内容
            ScrollView {
                Text(content)
                    .font(.system(size: 16))
                    .foregroundColor(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)
            }

            // 提示
            Text(isFront ? "点击翻转查看答案" : "点击翻转回到问题")
                .font(.system(size: 12))
                .foregroundColor(AppColor.textSecondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 280)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

/// 质量评分组件（简化4级）
struct QualityRatingView: View {
    let onRate: (SimplifiedQuality) -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("你记得怎么样？")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppColor.textPrimary)

            HStack(spacing: 12) {
                ForEach(SimplifiedQuality.allCases, id: \.rawValue) { quality in
                    QualityButton(quality: quality) {
                        withAnimation(.easeInOut) {
                            onRate(quality)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

/// 评分按钮
struct QualityButton: View {
    let quality: SimplifiedQuality
    let action: () -> Void

    private var color: Color {
        switch quality {
        case .forgot: return AppColor.error
        case .hard: return AppColor.warning
        case .hesitant: return AppColor.info
        case .perfect: return AppColor.primary
        }
    }

    private var icon: String {
        switch quality {
        case .forgot: return "xmark.circle.fill"
        case .hard: return "exclamationmark.circle.fill"
        case .hesitant: return "checkmark.circle"
        case .perfect: return "star.circle.fill"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)

                Text(quality.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(10)
        }
    }
}
