package com.card.learn.service;

import com.alibaba.fastjson2.JSON;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.dto.CardAuditDTO;
import com.card.learn.dto.CardCreateDTO;
import com.card.learn.entity.BizCard;
import com.card.learn.entity.BizCardDraft;
import com.card.learn.entity.BizCardTag;
import com.card.learn.mapper.BizCardDraftMapper;
import com.card.learn.service.impl.BizCardDraftServiceImpl;
import com.card.learn.vo.CardAuditVO;
import com.card.learn.vo.MyCardVO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * 临时卡片服务测试类（方案一：临时表存储）
 */
@ExtendWith(MockitoExtension.class)
class BizCardDraftServiceTest {

    @Mock
    private BizCardDraftMapper draftMapper;

    @Mock
    private IBizCardService cardService;

    @Mock
    private IBizCardTagService cardTagService;

    @Mock
    private IBizCardAuditLogService auditLogService;

    @Spy
    @InjectMocks
    private BizCardDraftServiceImpl draftService;

    private BizCardDraft testDraft;
    private CardCreateDTO createDTO;
    private CardAuditDTO auditDTO;

    @BeforeEach
    void setUp() {
        // 初始化测试临时卡片
        testDraft = new BizCardDraft();
        testDraft.setDraftId(1L);
        testDraft.setSubjectId(1L);
        testDraft.setFrontContent("测试问题");
        testDraft.setBackContent("测试答案");
        testDraft.setDifficultyLevel(2);
        testDraft.setAuditStatus("0");
        testDraft.setCreateUserId(100L);
        testDraft.setTagIds("[1, 2]");
        testDraft.setCreateTime(LocalDateTime.now());

        // 初始化创建DTO
        createDTO = new CardCreateDTO();
        createDTO.setSubjectId(1L);
        createDTO.setFrontContent("新问题");
        createDTO.setBackContent("新答案");
        createDTO.setDifficultyLevel(3);
        createDTO.setCreateUserId(100L);
        createDTO.setTagIds(Arrays.asList(1L, 2L));

        // 初始化审批DTO
        auditDTO = new CardAuditDTO();
        auditDTO.setCardId(1L);
        auditDTO.setAuditStatus("1");
        auditDTO.setAuditUserId(1L);
        auditDTO.setAuditRemark("审批通过");
    }

    @Test
    @DisplayName("测试用户录入临时卡片")
    void testCreateDraftCard() {
        // 模拟save方法
        doAnswer(invocation -> {
            BizCardDraft draft = invocation.getArgument(0);
            draft.setDraftId(2L);
            return true;
        }).when(draftService).save(any(BizCardDraft.class));

        // 执行创建
        Long draftId = draftService.createDraftCard(createDTO);

        // 验证结果
        assertNotNull(draftId);
        verify(draftService).save(any(BizCardDraft.class));
    }

    @Test
    @DisplayName("测试审批通过 - 迁移到正式表")
    void testAuditDraftCardPass() {
        // 模拟getById返回待审批临时卡片
        doReturn(testDraft).when(draftService).getById(1L);
        
        // 模拟创建正式卡片
        doAnswer(invocation -> {
            BizCard card = invocation.getArgument(0);
            card.setCardId(100L);
            return true;
        }).when(cardService).save(any(BizCard.class));
        
        // 模拟更新临时卡片状态
        doReturn(true).when(draftService).updateById(any(BizCardDraft.class));
        
        // 模拟设置标签
        doNothing().when(cardTagService).setCardTags(anyLong(), anyList());
        
        // 模拟记录审批日志
        doNothing().when(auditLogService).saveAuditLog(anyLong(), anyLong(), any(), anyLong(), any());

        // 执行审批（通过）
        auditDTO.setAuditStatus("1");
        Long cardId = draftService.auditDraftCard(auditDTO);

        // 验证结果：返回正式卡片ID
        assertNotNull(cardId);
        assertEquals(100L, cardId);
        
        // 验证正式卡片被创建
        verify(cardService).save(any(BizCard.class));
        
        // 验证标签被设置
        verify(cardTagService).setCardTags(eq(100L), anyList());
        
        // 验证审批日志被记录
        verify(auditLogService).saveAuditLog(eq(1L), eq(100L), eq("1"), eq(1L), any());
    }

    @Test
    @DisplayName("测试审批拒绝 - 不迁移到正式表")
    void testAuditDraftCardReject() {
        // 模拟getById返回待审批临时卡片
        doReturn(testDraft).when(draftService).getById(1L);
        
        // 模拟更新临时卡片状态
        doReturn(true).when(draftService).updateById(any(BizCardDraft.class));
        
        // 模拟记录审批日志
        doNothing().when(auditLogService).saveAuditLog(anyLong(), eq(null), any(), anyLong(), any());

        // 执行审批（拒绝）
        auditDTO.setAuditStatus("2");
        auditDTO.setAuditRemark("内容不符合规范");
        Long cardId = draftService.auditDraftCard(auditDTO);

        // 验证结果：返回null（未创建正式卡片）
        assertNull(cardId);
        
        // 验证正式卡片未被创建
        verify(cardService, never()).save(any(BizCard.class));
        
        // 验证审批日志被记录（cardId为null）
        verify(auditLogService).saveAuditLog(eq(1L), eq(null), eq("2"), eq(1L), any());
    }

    @Test
    @DisplayName("测试审批已审批卡片-应抛出异常")
    void testAuditAlreadyAuditedDraft() {
        // 模拟getById返回已审批临时卡片
        testDraft.setAuditStatus("1");
        doReturn(testDraft).when(draftService).getById(1L);

        // 执行审批，期望抛出异常
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            draftService.auditDraftCard(auditDTO);
        });

        assertTrue(exception.getMessage().contains("已审批"));
    }

    @Test
    @DisplayName("测试审批不存在的卡片-应抛出异常")
    void testAuditNonExistentDraft() {
        // 模拟getById返回null
        doReturn(null).when(draftService).getById(999L);

        auditDTO.setCardId(999L);

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            draftService.auditDraftCard(auditDTO);
        });

        assertTrue(exception.getMessage().contains("不存在"));
    }

    @Test
    @DisplayName("测试用户修改自己的临时卡片-待审批状态")
    void testUpdateMyDraftCardPending() {
        // 模拟getById返回待审批临时卡片
        doReturn(testDraft).when(draftService).getById(1L);
        doReturn(true).when(draftService).updateById(any(BizCardDraft.class));

        createDTO.setTagIds(Arrays.asList(1L, 2L, 3L));
        draftService.updateMyDraftCard(1L, createDTO, 100L);

        verify(draftService).updateById(any(BizCardDraft.class));
    }

    @Test
    @DisplayName("测试用户修改自己的临时卡片-已通过状态应抛出异常")
    void testUpdateMyDraftCardApproved() {
        testDraft.setAuditStatus("1");
        doReturn(testDraft).when(draftService).getById(1L);

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            draftService.updateMyDraftCard(1L, createDTO, 100L);
        });

        assertTrue(exception.getMessage().contains("待审批"));
    }

    @Test
    @DisplayName("测试用户修改他人临时卡片-应抛出异常")
    void testUpdateOtherUserDraft() {
        testDraft.setCreateUserId(200L);
        doReturn(testDraft).when(draftService).getById(1L);

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            draftService.updateMyDraftCard(1L, createDTO, 100L);
        });

        assertTrue(exception.getMessage().contains("无权限"));
    }

    @Test
    @DisplayName("测试用户删除自己的临时卡片-待审批状态")
    void testDeleteMyDraftCardPending() {
        doReturn(testDraft).when(draftService).getById(1L);
        doReturn(true).when(draftService).removeById(1L);

        draftService.deleteMyDraftCard(1L, 100L);

        verify(draftService).removeById(eq(1L));
    }

    @Test
    @DisplayName("测试用户删除自己的临时卡片-已通过状态应抛出异常")
    void testDeleteMyDraftCardApproved() {
        testDraft.setAuditStatus("1");
        doReturn(testDraft).when(draftService).getById(1L);

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            draftService.deleteMyDraftCard(1L, 100L);
        });

        assertTrue(exception.getMessage().contains("待审批"));
    }

    @Test
    @DisplayName("测试用户删除他人临时卡片-应抛出异常")
    void testDeleteOtherUserDraft() {
        testDraft.setCreateUserId(200L);
        doReturn(testDraft).when(draftService).getById(1L);

        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            draftService.deleteMyDraftCard(1L, 100L);
        });

        assertTrue(exception.getMessage().contains("无权限"));
    }

    @Test
    @DisplayName("测试DTO字段验证")
    void testDTOFields() {
        CardCreateDTO dto = new CardCreateDTO();
        dto.setSubjectId(1L);
        dto.setFrontContent("问题");
        dto.setBackContent("答案");
        dto.setDifficultyLevel(3);
        dto.setCreateUserId(100L);
        dto.setTagIds(Arrays.asList(1L, 2L));

        assertEquals(1L, dto.getSubjectId());
        assertEquals("问题", dto.getFrontContent());
        assertEquals("答案", dto.getBackContent());
        assertEquals(3, dto.getDifficultyLevel());
        assertEquals(100L, dto.getCreateUserId());
        assertEquals(2, dto.getTagIds().size());

        CardAuditDTO auditDto = new CardAuditDTO();
        auditDto.setCardId(1L);
        auditDto.setAuditStatus("1");
        auditDto.setAuditUserId(1L);
        auditDto.setAuditRemark("备注");

        assertEquals(1L, auditDto.getCardId());
        assertEquals("1", auditDto.getAuditStatus());
        assertEquals(1L, auditDto.getAuditUserId());
        assertEquals("备注", auditDto.getAuditRemark());
    }

    @Test
    @DisplayName("测试临时卡片实体字段")
    void testDraftEntityFields() {
        BizCardDraft draft = new BizCardDraft();
        draft.setDraftId(1L);
        draft.setSubjectId(1L);
        draft.setFrontContent("问题");
        draft.setBackContent("答案");
        draft.setDifficultyLevel(3);
        draft.setAuditStatus("0");
        draft.setCreateUserId(100L);
        draft.setTagIds("[1, 2]");
        draft.setAuditUserId(1L);
        draft.setAuditTime(LocalDateTime.now());
        draft.setAuditRemark("审批备注");

        assertEquals(1L, draft.getDraftId());
        assertEquals(1L, draft.getSubjectId());
        assertEquals("问题", draft.getFrontContent());
        assertEquals("答案", draft.getBackContent());
        assertEquals(3, draft.getDifficultyLevel());
        assertEquals("0", draft.getAuditStatus());
        assertEquals(100L, draft.getCreateUserId());
        assertEquals("[1, 2]", draft.getTagIds());
        assertEquals(1L, draft.getAuditUserId());
        assertNotNull(draft.getAuditTime());
        assertEquals("审批备注", draft.getAuditRemark());
    }

    @Test
    @DisplayName("测试分页查询待审批临时卡片-空列表")
    void testPagePendingDraftsEmpty() {
        Page<CardAuditVO> mockPage = new Page<>(1, 10);
        mockPage.setRecords(new ArrayList<>());
        mockPage.setTotal(0);

        when(draftMapper.selectPendingDrafts(any(Page.class), any())).thenReturn(mockPage);

        Page<CardAuditVO> result = draftService.pagePendingDrafts(null, 1, 10);

        assertNotNull(result);
        assertEquals(0, result.getTotal());
        assertTrue(result.getRecords().isEmpty());
    }

    @Test
    @DisplayName("测试分页查询我的临时卡片-空列表")
    void testPageMyDraftsEmpty() {
        Page<MyCardVO> mockPage = new Page<>(1, 10);
        mockPage.setRecords(new ArrayList<>());
        mockPage.setTotal(0);

        when(draftMapper.selectMyDrafts(any(Page.class), eq(100L))).thenReturn(mockPage);

        Page<MyCardVO> result = draftService.pageMyDrafts(100L, 1, 10);

        assertNotNull(result);
        assertEquals(0, result.getTotal());
        assertTrue(result.getRecords().isEmpty());
    }
}