<template>
  <div class="portal">
    <!-- 导航栏 -->
    <nav class="navbar" :class="{ scrolled }">
      <div class="nav-inner">
        <div class="nav-brand">
          <span class="brand-icon">📚</span>
          <span class="brand-text">Card Learn</span>
        </div>
        <div class="nav-links">
          <a href="#features">功能特色</a>
          <a href="#tech">技术架构</a>
          <a href="https://github.com" target="_blank">GitHub</a>
        </div>
        <div class="nav-actions">
          <el-button text class="nav-btn" @click="$router.push('/login')">登录</el-button>
          <el-button type="primary" class="nav-cta" @click="$router.push('/login?tab=register')">免费注册</el-button>
        </div>
      </div>
    </nav>

    <!-- Hero 区域 -->
    <section class="hero">
      <div class="hero-bg">
        <div class="floating-shapes">
          <div class="shape shape-1"></div>
          <div class="shape shape-2"></div>
          <div class="shape shape-3"></div>
          <div class="shape shape-4"></div>
          <div class="shape shape-5"></div>
        </div>
        <div class="grid-overlay"></div>
      </div>
      <div class="hero-content">
        <div class="hero-badge">考研人专属</div>
        <h1 class="hero-title">
          <span class="title-line">考研知识点</span>
          <span class="title-line gradient-text">学习卡片系统</span>
        </h1>
        <p class="hero-desc">
          基于间隔重复算法的智能学习工具，帮助你高效记忆考研核心知识点，科学规划复习节奏，轻松备考。
        </p>
        <div class="hero-actions">
          <el-button type="primary" size="large" class="hero-btn primary" @click="$router.push('/login')">
            开始学习
            <el-icon class="btn-arrow"><ArrowRight /></el-icon>
          </el-button>
          <el-button size="large" class="hero-btn ghost" @click="scrollToFeatures">
            了解更多
          </el-button>
        </div>
      </div>
      <div class="hero-visual">
        <div class="card-preview">
          <div class="preview-card" :class="{ flipped: previewFlipped }" @click="previewFlipped = !previewFlipped">
            <div class="preview-front">
              <div class="preview-subject">数据结构</div>
              <div class="preview-question">什么是二叉排序树（BST）？</div>
              <div class="preview-hint">点击翻转查看答案</div>
            </div>
            <div class="preview-back">
              <div class="preview-answer">
                二叉排序树是一棵二叉树，其中每个节点的值大于左子树所有节点的值，小于右子树所有节点的值。支持高效的查找、插入和删除操作，平均时间复杂度 O(log n)。
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 数据展示区 -->
    <section class="stats-section">
      <div class="stats-inner">
        <div class="stat-item" v-for="stat in stats" :key="stat.label">
          <div class="stat-number">
            <span class="stat-value">{{ animatedStats[stat.key] || 0 }}</span>
            <span class="stat-suffix">{{ stat.suffix }}</span>
          </div>
          <div class="stat-label">{{ stat.label }}</div>
        </div>
      </div>
    </section>

    <!-- 功能特色 -->
    <section id="features" class="features-section">
      <div class="section-header">
        <h2 class="section-title">功能特色</h2>
        <p class="section-desc">专为考研复习设计的智能学习工具</p>
      </div>
      <div class="features-grid">
        <div
          v-for="(feature, index) in features"
          :key="feature.title"
          class="feature-card"
          :class="{ visible: featuresVisible[index] }"
        >
          <div class="feature-icon">{{ feature.icon }}</div>
          <h3 class="feature-title">{{ feature.title }}</h3>
          <p class="feature-desc">{{ feature.desc }}</p>
        </div>
      </div>
    </section>

    <!-- 技术架构 -->
    <section id="tech" class="tech-section">
      <div class="section-header">
        <h2 class="section-title">技术架构</h2>
        <p class="section-desc">现代化全栈技术驱动</p>
      </div>
      <div class="tech-grid">
        <div v-for="tech in techStack" :key="tech.name" class="tech-item">
          <div class="tech-icon">{{ tech.icon }}</div>
          <div class="tech-info">
            <div class="tech-name">{{ tech.name }}</div>
            <div class="tech-role">{{ tech.role }}</div>
          </div>
        </div>
      </div>
    </section>

    <!-- 页脚 -->
    <footer class="footer">
      <div class="footer-inner">
        <div class="footer-brand">
          <span class="brand-icon">📚</span>
          <span class="brand-text">Card Learn</span>
        </div>
        <div class="footer-links">
          <a href="https://github.com" target="_blank">GitHub</a>
          <span class="footer-sep">|</span>
          <span>MIT License</span>
        </div>
        <div class="footer-copy">&copy; 2026 Card Learn. Built for Graduate Exam Preparation.</div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { ArrowRight } from '@element-plus/icons-vue'

const scrolled = ref(false)
const previewFlipped = ref(false)
const animatedStats = reactive<Record<string, number>>({})
const featuresVisible = ref([false, false, false, false])

const stats = [
  { key: 'cards', value: 500, suffix: '+', label: '知识卡片' },
  { key: 'subjects', value: 4, suffix: '门', label: '考研科目' },
  { key: 'reviews', value: 10000, suffix: '+', label: '累计复习次数' }
]

const features = [
  {
    icon: '🧠',
    title: '智能学习',
    desc: '基于艾宾浩斯遗忘曲线的间隔重复算法，自动规划最佳复习时间，让记忆更持久。'
  },
  {
    icon: '📊',
    title: '数据驱动',
    desc: '详细的学习数据统计，清晰掌握各科目学习进度，精准定位薄弱环节。'
  },
  {
    icon: '🏆',
    title: '成就激励',
    desc: '丰富的成就系统和排行榜，用游戏化的方式保持学习动力，每天进步一点点。'
  },
  {
    icon: '📱',
    title: '多端同步',
    desc: '支持 Web、微信小程序、iOS 客户端，随时随地利用碎片时间学习。'
  }
]

const techStack = [
  { icon: '☕', name: 'Spring Boot', role: '后端框架' },
  { icon: '🟢', name: 'Vue 3', role: 'Web 前端' },
  { icon: '🍎', name: 'Swift', role: 'iOS 客户端' },
  { icon: '💬', name: '微信小程序', role: '小程序端' },
  { icon: '🗄️', name: 'MySQL 8', role: '关系数据库' },
  { icon: '⚡', name: 'Redis', role: '缓存与会话' }
]

const handleScroll = () => {
  scrolled.value = window.scrollY > 50

  // 功能卡片滚动渐入
  const featureCards = document.querySelectorAll('.feature-card')
  featureCards.forEach((card, index) => {
    const rect = card.getBoundingClientRect()
    if (rect.top < window.innerHeight * 0.85) {
      featuresVisible.value[index] = true
    }
  })
}

const scrollToFeatures = () => {
  document.getElementById('features')?.scrollIntoView({ behavior: 'smooth' })
}

// 数字递增动画
const animateNumber = (key: string, target: number) => {
  const duration = 2000
  const startTime = Date.now()
  const step = () => {
    const elapsed = Date.now() - startTime
    const progress = Math.min(elapsed / duration, 1)
    // easeOutQuart
    const eased = 1 - Math.pow(1 - progress, 4)
    animatedStats[key] = Math.round(eased * target)
    if (progress < 1) {
      requestAnimationFrame(step)
    }
  }
  requestAnimationFrame(step)
}

const statsAnimated = ref(false)

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
  handleScroll()

  // Intersection Observer 触发数字动画
  const statsSection = document.querySelector('.stats-section')
  if (statsSection) {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !statsAnimated.value) {
          statsAnimated.value = true
          stats.forEach((s) => animateNumber(s.key, s.value))
        }
      },
      { threshold: 0.3 }
    )
    observer.observe(statsSection)
  }
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>

<style scoped lang="scss">
.portal {
  min-height: 100vh;
  overflow-x: hidden;
}

// ========== 导航栏 ==========
.navbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  padding: 0 40px;
  height: 64px;
  display: flex;
  align-items: center;
  transition: all 0.3s ease;

  &.scrolled {
    background: rgba(255, 255, 255, 0.72);
    backdrop-filter: blur(20px);
    border-bottom: 1px solid rgba(255, 255, 255, 0.2);
    box-shadow: 0 4px 30px rgba(0, 0, 0, 0.06);
  }
}

.nav-inner {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
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
  color: #fff;

  .scrolled & {
    color: #1a1a2e;
  }

  .brand-icon {
    font-size: 24px;
  }
}

.nav-links {
  display: flex;
  gap: 32px;

  a {
    color: rgba(255, 255, 255, 0.8);
    text-decoration: none;
    font-size: 14px;
    font-weight: 500;
    transition: color 0.3s;

    &:hover {
      color: #fff;
    }

    .scrolled & {
      color: #555;
      &:hover {
        color: #667eea;
      }
    }
  }
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.nav-btn {
  color: rgba(255, 255, 255, 0.9) !important;
  font-weight: 500;

  .scrolled & {
    color: #555 !important;
  }
}

.nav-cta {
  border-radius: 20px;
  padding: 8px 24px;
  background: rgba(255, 255, 255, 0.2) !important;
  border: 1px solid rgba(255, 255, 255, 0.3) !important;
  color: #fff !important;
  font-weight: 500;
  backdrop-filter: blur(10px);

  .scrolled & {
    background: linear-gradient(135deg, #667eea, #764ba2) !important;
    border: none !important;
  }
}

// ========== Hero 区域 ==========
.hero {
  position: relative;
  min-height: 100vh;
  display: flex;
  align-items: center;
  padding: 100px 40px 80px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
  overflow: hidden;
}

.hero-bg {
  position: absolute;
  inset: 0;
  overflow: hidden;
}

.floating-shapes .shape {
  position: absolute;
  border-radius: 50%;
  opacity: 0.12;
  animation: float 20s ease-in-out infinite;

  &.shape-1 {
    width: 300px;
    height: 300px;
    background: #fff;
    top: -5%;
    right: 10%;
    animation-delay: 0s;
  }

  &.shape-2 {
    width: 200px;
    height: 200px;
    background: #f0f;
    bottom: 10%;
    left: 5%;
    animation-delay: -5s;
  }

  &.shape-3 {
    width: 150px;
    height: 150px;
    background: #0ff;
    top: 40%;
    right: 30%;
    animation-delay: -10s;
  }

  &.shape-4 {
    width: 100px;
    height: 100px;
    background: #ff0;
    top: 20%;
    left: 20%;
    animation-delay: -15s;
  }

  &.shape-5 {
    width: 250px;
    height: 250px;
    background: #fff;
    bottom: -5%;
    right: -5%;
    animation-delay: -8s;
  }
}

.grid-overlay {
  position: absolute;
  inset: 0;
  background-image:
    linear-gradient(rgba(255, 255, 255, 0.05) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, 0.05) 1px, transparent 1px);
  background-size: 60px 60px;
}

.hero-content {
  position: relative;
  z-index: 2;
  max-width: 600px;
  flex: 1;
}

.hero-badge {
  display: inline-block;
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  padding: 6px 20px;
  font-size: 13px;
  color: #fff;
  font-weight: 500;
  margin-bottom: 28px;
  letter-spacing: 1px;
}

.hero-title {
  font-size: 52px;
  font-weight: 800;
  color: #fff;
  line-height: 1.2;
  margin: 0 0 24px;
  letter-spacing: 2px;

  .title-line {
    display: block;
  }

  .gradient-text {
    background: linear-gradient(90deg, #fff 0%, #f0e6ff 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
}

.hero-desc {
  font-size: 17px;
  color: rgba(255, 255, 255, 0.85);
  line-height: 1.8;
  margin: 0 0 40px;
}

.hero-actions {
  display: flex;
  gap: 16px;
}

.hero-btn {
  height: 50px;
  padding: 0 36px;
  border-radius: 25px;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 2px;
  transition: all 0.3s;

  &.primary {
    background: #fff !important;
    border: none !important;
    color: #667eea !important;
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 12px 40px rgba(0, 0, 0, 0.2);
    }
  }

  &.ghost {
    background: transparent !important;
    border: 2px solid rgba(255, 255, 255, 0.4) !important;
    color: #fff !important;

    &:hover {
      background: rgba(255, 255, 255, 0.1) !important;
      border-color: rgba(255, 255, 255, 0.6) !important;
    }
  }

  .btn-arrow {
    margin-left: 6px;
    transition: transform 0.3s;
  }

  &:hover .btn-arrow {
    transform: translateX(4px);
  }
}

// Hero 右侧卡片预览
.hero-visual {
  position: relative;
  z-index: 2;
  flex: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  perspective: 1000px;
}

.card-preview {
  width: 360px;
  height: 280px;
}

.preview-card {
  width: 100%;
  height: 100%;
  position: relative;
  cursor: pointer;
  transform-style: preserve-3d;
  transition: transform 0.8s cubic-bezier(0.4, 0, 0.2, 1);

  &.flipped {
    transform: rotateY(180deg);
  }
}

.preview-front,
.preview-back {
  position: absolute;
  inset: 0;
  border-radius: 20px;
  padding: 32px;
  backface-visibility: hidden;
  display: flex;
  flex-direction: column;
}

.preview-front {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);

  .preview-subject {
    font-size: 12px;
    font-weight: 600;
    color: #667eea;
    background: linear-gradient(135deg, #667eea20, #764ba220);
    padding: 4px 12px;
    border-radius: 12px;
    display: inline-block;
    width: fit-content;
    margin-bottom: 20px;
  }

  .preview-question {
    font-size: 18px;
    font-weight: 600;
    color: #1a1a2e;
    line-height: 1.6;
    flex: 1;
  }

  .preview-hint {
    font-size: 12px;
    color: #aaa;
    text-align: center;
  }
}

.preview-back {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff;
  transform: rotateY(180deg);
  box-shadow: 0 20px 60px rgba(102, 126, 234, 0.3);

  .preview-answer {
    font-size: 14px;
    line-height: 1.8;
    opacity: 0.95;
  }
}

// ========== 数据展示区 ==========
.stats-section {
  position: relative;
  z-index: 2;
  margin-top: -50px;
  padding: 0 40px;
}

.stats-inner {
  max-width: 900px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  background: #fff;
  border-radius: 20px;
  padding: 48px 40px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.08);
}

.stat-item {
  text-align: center;

  &:not(:last-child) {
    border-right: 1px solid #f0f0f0;
  }
}

.stat-number {
  margin-bottom: 8px;

  .stat-value {
    font-size: 48px;
    font-weight: 800;
    background: linear-gradient(135deg, #667eea, #764ba2);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .stat-suffix {
    font-size: 18px;
    color: #999;
    margin-left: 4px;
  }
}

.stat-label {
  font-size: 15px;
  color: #888;
}

// ========== 功能特色 ==========
.features-section {
  padding: 120px 40px;
  max-width: 1200px;
  margin: 0 auto;
}

.section-header {
  text-align: center;
  margin-bottom: 60px;
}

.section-title {
  font-size: 36px;
  font-weight: 700;
  color: #1a1a2e;
  margin: 0 0 12px;
}

.section-desc {
  font-size: 16px;
  color: #888;
  margin: 0;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
}

.feature-card {
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.8);
  border-radius: 20px;
  padding: 36px 28px;
  text-align: center;
  transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  opacity: 0;
  transform: translateY(40px);

  &.visible {
    opacity: 1;
    transform: translateY(0);
  }

  &:nth-child(1) { transition-delay: 0s; }
  &:nth-child(2) { transition-delay: 0.1s; }
  &:nth-child(3) { transition-delay: 0.2s; }
  &:nth-child(4) { transition-delay: 0.3s; }

  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 20px 60px rgba(102, 126, 234, 0.12);
    border-color: rgba(102, 126, 234, 0.2);
  }
}

.feature-icon {
  font-size: 48px;
  margin-bottom: 20px;
}

.feature-title {
  font-size: 20px;
  font-weight: 700;
  color: #1a1a2e;
  margin: 0 0 12px;
}

.feature-desc {
  font-size: 14px;
  color: #777;
  line-height: 1.7;
  margin: 0;
}

// ========== 技术架构 ==========
.tech-section {
  padding: 80px 40px 120px;
  max-width: 1000px;
  margin: 0 auto;
}

.tech-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.tech-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px 24px;
  background: #fff;
  border-radius: 16px;
  border: 1px solid #f0f0f0;
  transition: all 0.3s;

  &:hover {
    border-color: #667eea40;
    box-shadow: 0 8px 30px rgba(102, 126, 234, 0.08);
  }
}

.tech-icon {
  font-size: 32px;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea10, #764ba210);
  border-radius: 12px;
  flex-shrink: 0;
}

.tech-name {
  font-size: 15px;
  font-weight: 600;
  color: #1a1a2e;
}

.tech-role {
  font-size: 13px;
  color: #999;
  margin-top: 2px;
}

// ========== 页脚 ==========
.footer {
  padding: 48px 40px;
  background: #1a1a2e;
  color: rgba(255, 255, 255, 0.6);
}

.footer-inner {
  max-width: 1200px;
  margin: 0 auto;
  text-align: center;
}

.footer-brand {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  font-size: 20px;
  font-weight: 700;
  color: #fff;
  margin-bottom: 16px;

  .brand-icon {
    font-size: 24px;
  }
}

.footer-links {
  margin-bottom: 12px;

  a {
    color: rgba(255, 255, 255, 0.7);
    text-decoration: none;
    transition: color 0.3s;

    &:hover {
      color: #667eea;
    }
  }

  .footer-sep {
    margin: 0 12px;
    opacity: 0.3;
  }
}

.footer-copy {
  font-size: 13px;
  opacity: 0.5;
}

// ========== 动画 ==========
@keyframes float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  25% { transform: translateY(-20px) rotate(5deg); }
  50% { transform: translateY(10px) rotate(-3deg); }
  75% { transform: translateY(-15px) rotate(2deg); }
}

// ========== 响应式 ==========
@media (max-width: 1024px) {
  .hero {
    flex-direction: column;
    text-align: center;
    padding: 120px 24px 60px;
  }

  .hero-title {
    font-size: 38px;
  }

  .hero-desc {
    font-size: 15px;
  }

  .hero-actions {
    justify-content: center;
  }

  .hero-visual {
    margin-top: 48px;
  }

  .card-preview {
    width: 300px;
    height: 240px;
  }

  .features-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .tech-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .stats-inner {
    padding: 32px 24px;

    .stat-value {
      font-size: 36px;
    }
  }
}

@media (max-width: 640px) {
  .navbar {
    padding: 0 16px;
  }

  .nav-links {
    display: none;
  }

  .hero-title {
    font-size: 30px;
  }

  .features-grid {
    grid-template-columns: 1fr;
  }

  .tech-grid {
    grid-template-columns: 1fr;
  }

  .stats-inner {
    grid-template-columns: 1fr;
    gap: 16px;

    .stat-item:not(:last-child) {
      border-right: none;
      border-bottom: 1px solid #f0f0f0;
      padding-bottom: 16px;
    }
  }
}
</style>
