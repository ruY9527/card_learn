<template>
  <div class="learn-home">
    <!-- 顶部导航 -->
    <header class="learn-nav">
      <div class="nav-inner">
        <div class="nav-brand">
          <span class="brand-icon">📚</span>
          <span class="brand-text">Card Learn</span>
        </div>
        <div class="nav-user">
          <span class="user-name">{{ userStore.userInfo?.nickname || '同学' }}</span>
          <el-avatar :size="36" :src="userStore.userInfo?.avatar" class="user-avatar">
            {{ (userStore.userInfo?.nickname || 'U')[0] }}
          </el-avatar>
          <el-button text class="logout-btn" @click="handleLogout">退出</el-button>
        </div>
      </div>
    </header>

    <!-- 欢迎区 + 冲刺倒计时 -->
    <section class="welcome-section">
      <div class="welcome-inner">
        <div class="welcome-text">
          <h1>Hi, {{ userStore.userInfo?.nickname || '同学' }} 👋</h1>
          <p>今天也要加油学习哦！</p>
        </div>
        <div v-if="sprintConfig?.enabled && !sprintConfig?.isExpired" class="sprint-card">
          <div class="sprint-label">{{ sprintConfig.examName }}</div>
          <div class="sprint-days">
            <span class="days-number">{{ sprintConfig.daysRemaining }}</span>
            <span class="days-unit">天</span>
          </div>
          <div class="sprint-date">倒计时</div>
        </div>
      </div>
    </section>

    <!-- 统计卡片 -->
    <section class="stats-section">
      <div class="stats-grid">
        <div class="stat-card clickable" @click="$router.push('/learn/study?status=learned')">
          <div class="stat-icon" style="background: linear-gradient(135deg, #667eea20, #667eea40); color: #667eea;">📖</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.totalLearnRecords || 0 }}</div>
            <div class="stat-label">已学习</div>
          </div>
        </div>
        <div class="stat-card clickable" @click="$router.push('/learn/study?status=mastered')">
          <div class="stat-icon" style="background: linear-gradient(135deg, #67c23a20, #67c23a40); color: #67c23a;">✅</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.masteredCount || 0 }}</div>
            <div class="stat-label">已掌握</div>
          </div>
        </div>
        <div class="stat-card clickable" @click="$router.push('/learn/study?status=review')">
          <div class="stat-icon" style="background: linear-gradient(135deg, #e6a23c20, #e6a23c40); color: #e6a23c;">🔄</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.fuzzyCount || 0 }}</div>
            <div class="stat-label">待复习</div>
          </div>
        </div>
        <div class="stat-card clickable" @click="$router.push('/learn/heatmap')">
          <div class="stat-icon" style="background: linear-gradient(135deg, #f56c6c20, #f56c6c40); color: #f56c6c;">🔥</div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.learnDays || 0 }}</div>
            <div class="stat-label">学习天数</div>
          </div>
        </div>
      </div>
    </section>

    <!-- 快捷入口 -->
    <section class="shortcuts-section">
      <div class="shortcuts-grid">
        <div class="shortcut-card primary" @click="$router.push('/learn/study')">
          <div class="shortcut-icon">🎯</div>
          <div class="shortcut-info">
            <div class="shortcut-title">开始刷卡片</div>
            <div class="shortcut-desc">选择科目，开始高效学习</div>
          </div>
          <el-icon class="shortcut-arrow"><ArrowRight /></el-icon>
        </div>
        <div class="shortcut-card disabled">
          <div class="shortcut-icon">📅</div>
          <div class="shortcut-info">
            <div class="shortcut-title">复习计划</div>
            <div class="shortcut-desc">基于遗忘曲线的智能安排</div>
          </div>
          <div class="coming-soon">即将上线</div>
        </div>
        <div class="shortcut-card disabled">
          <div class="shortcut-icon">📊</div>
          <div class="shortcut-info">
            <div class="shortcut-title">学习历史</div>
            <div class="shortcut-desc">查看过往学习记录</div>
          </div>
          <div class="coming-soon">即将上线</div>
        </div>
      </div>
    </section>

    <!-- 今日推荐 -->
    <section v-if="recommendCards.length > 0" class="recommend-section">
      <div class="section-header">
        <h2>今日推荐</h2>
        <p>每个科目随机推荐一张卡片</p>
      </div>
      <div class="recommend-grid">
        <div
          v-for="card in recommendCards"
          :key="card.cardId"
          class="recommend-card"
          @click="$router.push(`/learn/study/${card.subjectId}`)"
        >
          <div class="recommend-top-row">
            <div class="recommend-subject">{{ card.subjectName }}</div>
            <div v-if="card.status != null" class="recommend-status" :class="`status-${card.status}`">
              {{ card.status === 2 ? '✓ 掌握' : card.status === 1 ? '~ 模糊' : '✗ 未学' }}
            </div>
          </div>
          <div class="recommend-content">{{ card.frontContent }}</div>
          <div class="recommend-footer">
            <span class="difficulty" :class="`level-${card.difficultyLevel}`">
              {{ ['', '简单', '中等', '困难'][card.difficultyLevel] || '未知' }}
            </span>
            <span class="go-study">去学习 →</span>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowRight } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { getLearnStats, getSprintConfigData, getRecommendCards } from '@/api/learn'

const router = useRouter()
const userStore = useUserStore()

const stats = ref<any>({})
const sprintConfig = ref<any>(null)
const recommendCards = ref<any[]>([])

const handleLogout = () => {
  userStore.logout()
  router.push('/login')
}

onMounted(async () => {
  try {
    const [statsRes, sprintRes, recommendRes] = await Promise.allSettled([
      getLearnStats(userStore.userInfo?.userId),
      getSprintConfigData(),
      getRecommendCards()
    ])
    if (statsRes.status === 'fulfilled') stats.value = statsRes.value.data
    if (sprintRes.status === 'fulfilled') sprintConfig.value = sprintRes.value.data
    if (recommendRes.status === 'fulfilled') recommendCards.value = recommendRes.value.data
  } catch {
    // 静默处理
  }
})
</script>

<style scoped lang="scss">
.learn-home {
  min-height: 100vh;
  background: #f5f7fb;
  padding-bottom: 80px;
}

// ========== 顶部导航 ==========
.learn-nav {
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
  position: sticky;
  top: 0;
  z-index: 50;
}

.nav-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 32px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.nav-brand {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 20px;
  font-weight: 700;
  color: #1a1a2e;

  .brand-icon {
    font-size: 24px;
  }
}

.nav-user {
  display: flex;
  align-items: center;
  gap: 12px;

  .user-name {
    font-size: 14px;
    color: #555;
    font-weight: 500;
  }

  .user-avatar {
    background: linear-gradient(135deg, #667eea, #764ba2);
    color: #fff;
    font-weight: 600;
  }

  .logout-btn {
    color: #999;
    font-size: 13px;

    &:hover {
      color: #f56c6c;
    }
  }
}

// ========== 欢迎区 ==========
.welcome-section {
  max-width: 1200px;
  margin: 0 auto;
  padding: 32px 32px 0;
}

.welcome-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border-radius: 20px;
  padding: 36px 40px;
  color: #fff;
}

.welcome-text {
  h1 {
    font-size: 28px;
    font-weight: 700;
    margin: 0 0 8px;
  }

  p {
    font-size: 15px;
    opacity: 0.85;
    margin: 0;
  }
}

.sprint-card {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 20px 32px;
  text-align: center;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.sprint-label {
  font-size: 13px;
  opacity: 0.85;
  margin-bottom: 8px;
}

.sprint-days {
  display: flex;
  align-items: baseline;
  justify-content: center;
  gap: 4px;

  .days-number {
    font-size: 48px;
    font-weight: 800;
    line-height: 1;
  }

  .days-unit {
    font-size: 16px;
    opacity: 0.85;
  }
}

.sprint-date {
  font-size: 12px;
  opacity: 0.7;
  margin-top: 4px;
}

// ========== 统计卡片 ==========
.stats-section {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px 32px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.stat-card {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  border: 1px solid #f0f0f0;
  transition: all 0.3s;

  &:hover {
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.06);
  }

  &.clickable {
    cursor: pointer;

    &:hover {
      transform: translateY(-2px);
      border-color: #667eea40;
    }
  }
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  flex-shrink: 0;
}

.stat-value {
  font-size: 28px;
  font-weight: 800;
  color: #1a1a2e;
}

.stat-label {
  font-size: 13px;
  color: #999;
  margin-top: 2px;
}

// ========== 快捷入口 ==========
.shortcuts-section {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 32px;
}

.shortcuts-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.shortcut-card {
  background: #fff;
  border-radius: 16px;
  padding: 28px;
  display: flex;
  align-items: center;
  gap: 20px;
  border: 1px solid #f0f0f0;
  cursor: pointer;
  transition: all 0.3s;

  &.primary {
    background: linear-gradient(135deg, #667eea10, #764ba210);
    border-color: #667eea30;

    &:hover {
      transform: translateY(-4px);
      box-shadow: 0 12px 40px rgba(102, 126, 234, 0.15);
      border-color: #667eea60;
    }
  }

  &.disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
}

.shortcut-icon {
  font-size: 36px;
  width: 56px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f8f9fd;
  border-radius: 16px;
  flex-shrink: 0;
}

.shortcut-info {
  flex: 1;
}

.shortcut-title {
  font-size: 17px;
  font-weight: 600;
  color: #1a1a2e;
  margin-bottom: 4px;
}

.shortcut-desc {
  font-size: 13px;
  color: #999;
}

.shortcut-arrow {
  color: #667eea;
  font-size: 20px;
}

.coming-soon {
  font-size: 12px;
  color: #bbb;
  background: #f5f5f5;
  padding: 4px 12px;
  border-radius: 10px;
}

// ========== 今日推荐 ==========
.recommend-section {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 32px 0;
}

.section-header {
  margin-bottom: 24px;

  h2 {
    font-size: 22px;
    font-weight: 700;
    color: #1a1a2e;
    margin: 0 0 4px;
  }

  p {
    font-size: 14px;
    color: #999;
    margin: 0;
  }
}

.recommend-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}

.recommend-card {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid #f0f0f0;
  cursor: pointer;
  transition: all 0.3s;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 40px rgba(0, 0, 0, 0.06);
  }
}

.recommend-top-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.recommend-subject {
  font-size: 12px;
  font-weight: 600;
  color: #667eea;
  background: linear-gradient(135deg, #667eea15, #764ba215);
  padding: 4px 12px;
  border-radius: 10px;
  display: inline-block;
}

.recommend-status {
  font-size: 11px;
  font-weight: 600;
  padding: 3px 10px;
  border-radius: 10px;

  &.status-0 {
    color: #9e9e9e;
    background: #9e9e9e15;
  }

  &.status-1 {
    color: #e6a23c;
    background: #e6a23c15;
  }

  &.status-2 {
    color: #67c23a;
    background: #67c23a15;
  }
}

.recommend-content {
  font-size: 15px;
  color: #333;
  line-height: 1.6;
  margin-bottom: 16px;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.recommend-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.difficulty {
  font-size: 12px;
  padding: 2px 10px;
  border-radius: 8px;

  &.level-1 {
    background: #67c23a15;
    color: #67c23a;
  }

  &.level-2 {
    background: #e6a23c15;
    color: #e6a23c;
  }

  &.level-3 {
    background: #f56c6c15;
    color: #f56c6c;
  }
}

.go-study {
  font-size: 13px;
  color: #667eea;
  font-weight: 500;
}

// ========== 响应式 ==========
@media (max-width: 768px) {
  .welcome-inner {
    flex-direction: column;
    text-align: center;
    gap: 20px;
    padding: 28px 24px;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .shortcuts-grid {
    grid-template-columns: 1fr;
  }

  .recommend-grid {
    grid-template-columns: 1fr;
  }
}
</style>
