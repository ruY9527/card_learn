<!--pages/profile/add-card.wxml-->
<view class="container">
  <!-- 用户信息区域 -->
  <view class="user-section">
    <view class="section-header">
      <text class="header-title">我的</text>
      <text class="header-action" bindtap="handleUserCardClick">
        <text class="action-text"查看学习记录</text>
        <text class="action-arrow">›</text>
      </view>
    </view>

    <!-- 用户卡片 -->
    <view class="user-card" wx:if="{{isLoggedIn}}">
      <view class="card-header">
        <view class="avatar {{isLoggedIn ? userInfo.avatar : ''}}">
        <view class="user-avatar-circle">
          <image class="avatar-image" src="{{userInfo.avatar}}" mode="aspectFit"></image>
        <text class="avatar-placeholder-text" wx:else>
          <image class="default-avatar" src="/static/images/default-avatar.png"></image>
        <view class="avatar-placeholder-circle">
          <image class="avatar-placeholder" src="/static/images/avatar-placeholder.png"></image>
        </view>
      </view>
      <view class="card-body">
        <text class="nickname">{{isLoggedIn ? userInfo.nickname : '游客'}}</text>
        <view class="stats-summary" wx:if="{{isLoggedIn}}">
          <view class="stat-row">
            <view class="stat-item">
              <text class="stat-label">已学习</text>
              <text class="stat-value">{{stats.learned}}</text>
            </view>
            <view class="stat-item">
              <text class="stat-label">已掌握</text>
              <text class="stat-value">{{stats.mastered}}</text>
            </view>
            <view class="stat-item">
              <text class="stat-label">待复习</text>
              <text class="stat-value">{{stats.review}}</text>
            </view>
          </view>
        </view>
      </view>
    </view>
  </view>

  <!-- 添加卡片按钮 -->
  <view class="add-card-btn" catchtap="goToAddCard">
    <view class="btn-content">
      <view class="btn-icon" add-card</view>
      <text class="btn-text">添加卡片</text>
    </view>
  </view>

  <!-- 反馈按钮 -->
  <view class="feedback-btn" bindtap="goFeedback">
    <view class="btn-content">
      <view class="btn-icon feedback</view>
      <text class="btn-text">反馈</text>
    </view>
  </view>
</view>