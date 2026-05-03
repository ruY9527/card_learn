<template>
  <div class="markdown-editor">
    <div class="editor-toolbar">
      <el-radio-group v-model="viewMode" size="small">
        <el-radio-button value="edit">编辑</el-radio-button>
        <el-radio-button value="preview">预览</el-radio-button>
        <el-radio-button value="split">分屏</el-radio-button>
      </el-radio-group>
    </div>
    <div class="editor-body" :class="{ 'split-mode': viewMode === 'split' }">
      <!-- 编辑区 -->
      <div v-show="viewMode !== 'preview'" class="editor-pane">
        <textarea
          ref="textareaRef"
          :value="modelValue"
          @input="handleInput"
          @scroll="handleEditorScroll"
          :placeholder="placeholder"
          class="editor-textarea"
        />
      </div>
      <!-- 预览区 -->
      <div v-show="viewMode !== 'edit'" class="preview-pane" ref="previewRef">
        <div class="markdown-body" v-html="renderedContent" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { marked } from 'marked'
import hljs from 'highlight.js'

// 配置 marked
marked.setOptions({
  highlight(code: string, lang: string) {
    if (lang && hljs.getLanguage(lang)) {
      return hljs.highlight(code, { language: lang }).value
    }
    return code
  },
  breaks: true,
  gfm: true
})

const props = withDefaults(defineProps<{
  modelValue?: string
  placeholder?: string
  height?: string
}>(), {
  modelValue: '',
  placeholder: '支持 Markdown 语法...',
  height: '400px'
})

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()

const viewMode = ref<'edit' | 'preview' | 'split'>('split')
const textareaRef = ref<HTMLTextAreaElement>()
const previewRef = ref<HTMLDivElement>()

const renderedContent = computed(() => {
  if (!props.modelValue) return '<p class="empty-hint">在左侧输入 Markdown 内容...</p>'
  return marked.parse(props.modelValue)
})

function handleInput(e: Event) {
  const target = e.target as HTMLTextAreaElement
  emit('update:modelValue', target.value)
}

function handleEditorScroll() {
  if (viewMode.value !== 'split' || !textareaRef.value || !previewRef.value) return
  const editor = textareaRef.value
  const preview = previewRef.value
  const ratio = editor.scrollTop / (editor.scrollHeight - editor.clientHeight)
  preview.scrollTop = ratio * (preview.scrollHeight - preview.clientHeight)
}
</script>

<style scoped lang="scss">
.markdown-editor {
  border: 1px solid var(--border-color, #dcdfe6);
  border-radius: 8px;
  overflow: hidden;
  background: var(--bg-color, #fff);

  .editor-toolbar {
    padding: 8px 12px;
    border-bottom: 1px solid var(--border-color-light, #e4e7ed);
    background: var(--fill-color-light, #f5f7fa);
  }

  .editor-body {
    display: flex;
    min-height: v-bind(height);

    &.split-mode {
      .editor-pane,
      .preview-pane {
        flex: 1;
        min-width: 0;
      }

      .editor-pane {
        border-right: 1px solid var(--border-color-light, #e4e7ed);
      }
    }
  }

  .editor-pane {
    flex: 1;

    .editor-textarea {
      width: 100%;
      height: 100%;
      min-height: v-bind(height);
      padding: 16px;
      border: none;
      outline: none;
      resize: vertical;
      font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
      font-size: 14px;
      line-height: 1.6;
      color: var(--text-color-primary, #303133);
      background: var(--bg-color, #fff);

      &::placeholder {
        color: var(--text-color-placeholder, #a8abb2);
      }
    }
  }

  .preview-pane {
    flex: 1;
    overflow-y: auto;
    padding: 16px;

    .markdown-body {
      font-size: 14px;
      line-height: 1.8;
      color: var(--text-color-primary, #303133);
      word-wrap: break-word;

      :deep(h1), :deep(h2), :deep(h3), :deep(h4) {
        margin-top: 16px;
        margin-bottom: 8px;
        font-weight: 600;
      }

      :deep(h1) { font-size: 24px; }
      :deep(h2) { font-size: 20px; }
      :deep(h3) { font-size: 16px; }

      :deep(p) {
        margin-bottom: 8px;
      }

      :deep(code) {
        padding: 2px 6px;
        font-family: 'SFMono-Regular', Consolas, monospace;
        font-size: 13px;
        background: var(--fill-color, #f0f2f5);
        border-radius: 4px;
        color: #e83e8c;
      }

      :deep(pre) {
        margin: 12px 0;
        padding: 16px;
        background: #282c34;
        border-radius: 8px;
        overflow-x: auto;

        code {
          padding: 0;
          background: transparent;
          color: #abb2bf;
          font-size: 13px;
          line-height: 1.5;
        }
      }

      :deep(blockquote) {
        margin: 12px 0;
        padding: 8px 16px;
        border-left: 4px solid var(--el-color-primary, #409eff);
        background: var(--fill-color-light, #f5f7fa);
        color: var(--text-color-regular, #606266);
      }

      :deep(ul), :deep(ol) {
        padding-left: 24px;
        margin-bottom: 8px;
      }

      :deep(li) {
        margin-bottom: 4px;
      }

      :deep(table) {
        width: 100%;
        border-collapse: collapse;
        margin: 12px 0;

        th, td {
          padding: 8px 12px;
          border: 1px solid var(--border-color, #dcdfe6);
          text-align: left;
        }

        th {
          background: var(--fill-color-light, #f5f7fa);
          font-weight: 600;
        }
      }

      :deep(img) {
        max-width: 100%;
        border-radius: 4px;
      }

      :deep(hr) {
        margin: 16px 0;
        border: none;
        border-top: 1px solid var(--border-color-light, #e4e7ed);
      }

      .empty-hint {
        color: var(--text-color-placeholder, #a8abb2);
        font-style: italic;
      }
    }
  }
}
</style>
