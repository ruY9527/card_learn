import SwiftUI

// 加载更多按钮
struct LoadMoreButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("加载更多")
                .font(.system(size: 14))
                .foregroundColor(AppColor.primary)
        }
        .padding(.vertical, 16)
    }
}

// 已加载全部提示
struct AllLoadedText: View {
    let total: Int

    var body: some View {
        Text("已加载全部 \(total) 张卡片")
            .font(.system(size: 13))
            .foregroundColor(AppColor.textSecondary)
            .padding(.vertical, 16)
    }
}

// 加载状态
struct LoadingSection: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColor.primary))

            Text("加载中...")
                .font(.system(size: 14))
                .foregroundColor(AppColor.textSecondary)
        }
        .padding(.vertical, 50)
    }
}
