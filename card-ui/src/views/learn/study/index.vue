<template>
  <div class="study-page">
    <!-- 顶部导航 -->
    <header class="study-nav">
      <div class="nav-inner">
        <div class="nav-left">
          <el-button text class="back-btn" @click="$router.push('/learn')">
            <el-icon><ArrowLeft /></el-icon>
            <span>返回</span>
          </el-button>
          <h1 class="page-title">刷知识卡片</h1>
        </div>
        <div class="nav-right">
          <el-tag
            v-if="currentStatus"
            closable
            type="primary"
            @close="clearStatusFilter"
          >
            {{ statusLabelMap[currentStatus] || currentStatus }}
          </el-tag>
          <el-select
            v-model="currentSubjectId"
            placeholder="全部科目"
            clearable
            size="default"
            class="subject-filter"
            @change="handleSubjectChange"
          >
            <el-option
              v-for="s in subjects"
              :key="s.subjectId"
              :label="s.subjectName"
              :value="s.subjectId"
            />
          </el-select>
        </div>
      </div>
    </header>

    <!-- 主体区域 -->
    <div class="study-body" v-if="cards.length > 0">
      <!-- 进度条 -->
      <div class="progress-section">
        <div class="progress-text">
          <span>{{ currentIndex + 1 }} / {{ cards.length }}</span>
          <span class="progress-percent">{{ Math.round(((currentIndex + 1) / cards.length) * 100) }}%</span>
        </div>
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: `${((currentIndex + 1) / cards.length) * 100}%` }"></div>
        </div>
      </div>

      <!-- 卡片区域 -->
      <div class="card-area">
        <div class="study-card" :class="{ flipped }" @click="flipped = !flipped">
          <div class="card-front">
            <div class="card-header-row">
              <div class="card-subject">{{ currentCard.subjectName }}</div>
              <div v-if="currentCard.status != null" class="status-badge" :class="`status-${currentCard.status}`">
                {{ currentCard.status === 2 ? '✓ 掌握' : currentCard.status === 1 ? '~ 模糊' : '✗ 未学' }}
              </div>
            </div>
            <div class="card-content" v-html="currentCard.frontContent"></div>
            <div class="flip-hint">
              <span>点击卡片或按空格键查看答案</span>
            </div>
          </div>
          <div class="card-back">
            <div class="card-subject">答案</div>
            <div class="card-content" v-html="currentCard.backContent"></div>
            <div class="flip-hint">
              <span>选择你的掌握程度</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 操作按钮 -->
      <div class="action-buttons">
        <button class="action-btn again" @click="markStatus(0)" :disabled="submitting">
          <span class="btn-emoji">✗</span>
          <span class="btn-label">不熟</span>
          <span class="btn-key">1</span>
        </button>
        <button class="action-btn fuzzy" @click="markStatus(1)" :disabled="submitting">
          <span class="btn-emoji">~</span>
          <span class="btn-label">模糊</span>
          <span class="btn-key">2</span>
        </button>
        <button class="action-btn mastered" @click="markStatus(2)" :disabled="submitting">
          <span class="btn-emoji">✓</span>
          <span class="btn-label">掌握</span>
          <span class="btn-key">3</span>
        </button>
      </div>

      <!-- 底部导航 -->
      <div class="bottom-nav">
        <el-button :disabled="currentIndex <= 0" @click="goPrev">
          <el-icon><ArrowLeft /></el-icon> 上一张
        </el-button>
        <el-button :disabled="currentIndex >= cards.length - 1" @click="goNext">
          下一张 <el-icon><ArrowRight /></el-icon>
        </el-button>
      </div>
    </div>

    <!-- 空状态 -->
    <div class="empty-state" v-else-if="!loading">
      <div class="empty-icon">📭</div>
      <h3>暂无卡片</h3>
      <p>该科目下还没有学习卡片</p>
      <el-button type="primary" @click="$router.push('/learn')">返回首页</el-button>
    </div>

    <!-- 加载状态 -->
    <div class="loading-state" v-if="loading">
      <div class="loading-spinner"></div>
      <p>加载中...</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { ArrowLeft, ArrowRight } from '@element-plus/icons-vue'
import { getSubjectList, getCardList, submitSimpleReview } from '@/api/learn'
import { useUserStore } from '@/store/user'

const route = useRoute()
const userStore = useUserStore()

const loading = ref(true)
const submitting = ref(false)
const subjects = ref<any[]>([])
const cards = ref<any[]>([])
const currentIndex = ref(0)
const flipped = ref(false)
const currentSubjectId = ref<number | undefined>(
  route.params.subjectId ? Number(route.params.subjectId) : undefined
)
const currentStatus = ref<string | undefined>(
  route.query.status as string | undefined
)

const currentCard = computed(() => cards.value[currentIndex.value] || {})

const statusLabelMap: Record<string, string> = {
  learned: '已学习',
  mastered: '已掌握',
  review: '待复习',
  unlearned: '未学习'
}

const clearStatusFilter = () => {
  currentStatus.value = undefined
  loadCards()
}

const loadSubjects = async () => {
  try {
    const res = await getSubjectList()
    subjects.value = res.data || []
  } catch {
    // 静默
  }
}

const loadCards = async () => {
  loading.value = true
  try {
    const params: any = { pageSize: 200, userId: userStore.userInfo?.userId }
    if (currentSubjectId.value) {
      params.subjectId = currentSubjectId.value
    }
    if (currentStatus.value) {
      params.status = currentStatus.value
    }
    const res = await getCardList(params)
    cards.value = res.data?.records || res.data || []
    currentIndex.value = 0
    flipped.value = false
  } catch {
    cards.value = []
  } finally {
    loading.value = false
  }
}

const handleSubjectChange = () => {
  loadCards()
}

const goNext = () => {
  if (currentIndex.value < cards.value.length - 1) {
    currentIndex.value++
    flipped.value = false
  }
}

const goPrev = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--
    flipped.value = false
  }
}

const markStatus = async (status: number) => {
  if (submitting.value) return
  submitting.value = true
  try {
    await submitSimpleReview({
      cardId: currentCard.value.cardId,
      userId: userStore.userInfo?.userId,
      status,
      source: 'web'
    })
    // 更新本地卡片状态
    cards.value[currentIndex.value].status = status
    // 自动下一张
    if (currentIndex.value < cards.value.length - 1) {
      currentIndex.value++
      flipped.value = false
    }
  } catch {
    // 错误已由拦截器处理
  } finally {
    submitting.value = false
  }
}

// 键盘快捷键
const handleKeydown = (e: KeyboardEvent) => {
  if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) return

  switch (e.key) {
    case ' ':
      e.preventDefault()
      flipped.value = !flipped.value
      break
    case '1':
      markStatus(0)
      break
    case '2':
      markStatus(1)
      break
    case '3':
      markStatus(2)
      break
    case 'ArrowLeft':
      goPrev()
      break
    case 'ArrowRight':
      goNext()
      break
  }
}

onMounted(async () => {
  window.addEventListener('keydown', handleKeydown)
  await Promise.all([loadSubjects(), loadCards()])
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped lang="scss">
.study-page {
  min-height: 100vh;
  background: #f5f7fb;
}

// ========== 顶部导航 ==========
.study-nav {
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

.nav-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.nav-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.back-btn {
  color: #666;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 4px;

  &:hover {
    color: #667eea;
  }
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #1a1a2e;
  margin: 0;
}

.subject-filter {
  width: 200px;
}

// ========== 进度条 ==========
.progress-section {
  max-width: 600px;
  margin: 0 auto;
  padding: 24px 32px 0;
}

.progress-text {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
  color: #666;

  .progress-percent {
    color: #667eea;
    font-weight: 600;
  }
}

.progress-bar {
  height: 6px;
  background: #e8e8e8;
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #667eea, #764ba2);
  border-radius: 3px;
  transition: width 0.4s ease;
}

// ========== 卡片区域 ==========
.card-area {
  max-width: 600px;
  margin: 0 auto;
  padding: 32px 32px 0;
  perspective: 1200px;
}

.study-card {
  width: 100%;
  min-height: 360px;
  position: relative;
  cursor: pointer;
  transform-style: preserve-3d;
  transition: transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);

  &.flipped {
    transform: rotateY(180deg);
  }
}

.card-front,
.card-back {
  position: absolute;
  inset: 0;
  border-radius: 24px;
  padding: 40px;
  backface-visibility: hidden;
  display: flex;
  flex-direction: column;
}

.card-front {
  background: #fff;
  box-shadow: 0 8px 40px rgba(0, 0, 0, 0.06);
  border: 1px solid #f0f0f0;

  .card-content {
    flex: 1;
    font-size: 20px;
    font-weight: 600;
    color: #1a1a2e;
    line-height: 1.7;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
  }
}

.card-back {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  transform: rotateY(180deg);
  box-shadow: 0 8px 40px rgba(102, 126, 234, 0.2);

  .card-content {
    flex: 1;
    font-size: 15px;
    line-height: 1.8;
    opacity: 0.95;
    overflow-y: auto;
    white-space: pre-wrap;
    word-break: break-word;
  }
}

.card-subject {
  font-size: 12px;
  font-weight: 600;
  padding: 4px 14px;
  border-radius: 12px;
  display: inline-block;
  width: fit-content;
  margin-bottom: 20px;
}

.card-header-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}

.card-header-row .card-subject {
  margin-bottom: 0;
}

.status-badge {
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

.card-front .card-subject {
  color: #667eea;
  background: linear-gradient(135deg, #667eea15, #764ba215);
}

.card-back .card-subject {
  color: #fff;
  background: rgba(255, 255, 255, 0.2);
}

.flip-hint {
  text-align: center;
  margin-top: 16px;

  span {
    font-size: 12px;
    opacity: 0.5;
  }
}

// ========== 操作按钮 ==========
.action-buttons {
  max-width: 600px;
  margin: 0 auto;
  padding: 32px;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.action-btn {
  background: #fff;
  border: 2px solid #f0f0f0;
  border-radius: 16px;
  padding: 16px 12px;
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  position: relative;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    transform: none;
  }

  .btn-emoji {
    font-size: 28px;
  }

  .btn-label {
    font-size: 14px;
    font-weight: 600;
    color: #333;
  }

  .btn-key {
    position: absolute;
    top: 8px;
    right: 10px;
    font-size: 10px;
    color: #ccc;
    background: #f5f5f5;
    width: 20px;
    height: 20px;
    border-radius: 6px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 600;
  }

  &.again {
    border-color: #f56c6c30;
    &:hover { border-color: #f56c6c60; background: #f56c6c08; }
  }

  &.fuzzy {
    border-color: #e6a23c30;
    &:hover { border-color: #e6a23c60; background: #e6a23c08; }
  }

  &.mastered {
    border-color: #67c23a30;
    &:hover { border-color: #67c23a60; background: #67c23a08; }
  }
}

// ========== 底部导航 ==========
.bottom-nav {
  max-width: 600px;
  margin: 0 auto;
  padding: 0 32px 40px;
  display: flex;
  justify-content: space-between;

  .el-button {
    border-radius: 12px;
    font-weight: 500;
  }
}

// ========== 空状态 ==========
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 120px 32px;
  text-align: center;

  .empty-icon {
    font-size: 64px;
    margin-bottom: 20px;
  }

  h3 {
    font-size: 20px;
    font-weight: 600;
    color: #1a1a2e;
    margin: 0 0 8px;
  }

  p {
    font-size: 14px;
    color: #999;
    margin: 0 0 24px;
  }
}

// ========== 加载状态 ==========
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 120px 32px;

  p {
    font-size: 14px;
    color: #999;
    margin-top: 16px;
  }
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #f0f0f0;
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

// ========== 响应式 ==========
@media (max-width: 640px) {
  .card-area {
    padding: 24px 16px 0;
  }

  .study-card {
    min-height: 300px;
  }

  .card-front .card-content {
    font-size: 17px;
  }

  .card-front,
  .card-back {
    padding: 28px 24px;
  }

  .action-buttons {
    padding: 24px 16px;
    gap: 8px;
  }

  .action-btn {
    padding: 12px 8px;

    .btn-emoji {
      font-size: 22px;
    }

    .btn-label {
      font-size: 12px;
    }
  }

  .subject-filter {
    width: 140px;
  }
}
</style>
