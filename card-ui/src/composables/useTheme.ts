import { ref, onMounted } from 'vue'

export type ThemeMode = 'light' | 'dark' | 'system'

const isDark = ref(false)
const themeMode = ref<ThemeMode>('light')

function applyTheme(dark: boolean) {
  document.documentElement.setAttribute('data-theme', dark ? 'dark' : 'light')
  // 同步 Element Plus 暗黑模式
  if (dark) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }
}

function getSystemTheme(): boolean {
  return window.matchMedia('(prefers-color-scheme: dark)').matches
}

export function useTheme() {
  const toggleTheme = () => {
    isDark.value = !isDark.value
    themeMode.value = isDark.value ? 'dark' : 'light'
    applyTheme(isDark.value)
    localStorage.setItem('theme', themeMode.value)
  }

  const setTheme = (mode: ThemeMode) => {
    themeMode.value = mode
    if (mode === 'system') {
      isDark.value = getSystemTheme()
    } else {
      isDark.value = mode === 'dark'
    }
    applyTheme(isDark.value)
    localStorage.setItem('theme', mode)
  }

  onMounted(() => {
    const saved = localStorage.getItem('theme') as ThemeMode | null
    if (saved) {
      setTheme(saved)
    } else {
      setTheme('system')
    }

    // 监听系统主题变化
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      if (themeMode.value === 'system') {
        isDark.value = e.matches
        applyTheme(isDark.value)
      }
    })
  })

  return {
    isDark,
    themeMode,
    toggleTheme,
    setTheme
  }
}
