package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.dto.CardAuditDTO;
import com.card.learn.dto.CardCreateDTO;
import com.card.learn.entity.BizCard;
import com.card.learn.entity.BizCardTag;
import com.card.learn.mapper.BizCardMapper;
import com.card.learn.service.impl.BizCardServiceImpl;
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
 * 卡片服务测试类
 */
@ExtendWith(MockitoExtension.class)
class BizCardServiceTest {

    @Mock
    private BizCardMapper cardMapper;

    @Mock
    private IBizCardTagService cardTagService;

    @Mock
    private IBizTagService tagService;

    @Spy
    @InjectMocks
    private BizCardServiceImpl cardService;

    private BizCard testCard;
    private CardCreateDTO createDTO;
    private CardAuditDTO auditDTO;

    @BeforeEach
    void setUp() {
        // 初始化测试卡片
        testCard = new BizCard();
        testCard.setCardId(1L);
        testCard.setSubjectId(1L);
        testCard.setFrontContent("测试问题");
        testCard.setBackContent("测试答案");
        testCard.setDifficultyLevel(2);
        testCard.setAuditStatus("0");
        testCard.setCreateUserId(100L);
        testCard.setCreateTime(LocalDateTime.now());

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
    @DisplayName("测试用户录入卡片")
    void testCreateCardByUser() {
        // 模拟save方法
        doAnswer(invocation -> {
            BizCard card = invocation.getArgument(0);
            card.setCardId(2L);
            return true;
        }).when(cardService).save(any(BizCard.class));
        
        // 模拟setCardTags方法
        doNothing().when(cardTagService).setCardTags(anyLong(), anyList());

        // 执行创建
        Long cardId = cardService.createCardByUser(createDTO);

        // 验证结果
        assertNotNull(cardId);

        // 验证标签设置被调用
        verify(cardTagService).setCardTags(anyLong(), eq(createDTO.getTagIds()));
    }

    @Test
    @DisplayName("测试审批卡片-通过")
    void testAuditCardPass() {
        // 模拟getById返回待审批卡片
        doReturn(testCard).when(cardService).getById(1L);
        doReturn(true).when(cardService).updateById(any(BizCard.class));

        // 执行审批
        auditDTO.setAuditStatus("1");
        cardService.auditCard(auditDTO);

        // 验证卡片状态被更新
        verify(cardService).updateById(any(BizCard.class));
    }

    @Test
    @DisplayName("测试审批卡片-拒绝")
    void testAuditCardReject() {
        // 模拟getById返回待审批卡片
        doReturn(testCard).when(cardService).getById(1L);
        doReturn(true).when(cardService).updateById(any(BizCard.class));

        // 执行审批
        auditDTO.setAuditStatus("2");
        auditDTO.setAuditRemark("内容不符合规范");
        cardService.auditCard(auditDTO);

        // 验证卡片状态被更新
        verify(cardService).updateById(any(BizCard.class));
    }

    @Test
    @DisplayName("测试审批已审批卡片-应抛出异常")
    void testAuditAlreadyAuditedCard() {
        // 模拟getById返回已审批卡片
        testCard.setAuditStatus("1");
        doReturn(testCard).when(cardService).getById(1L);

        // 执行审批，期望抛出异常
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            cardService.auditCard(auditDTO);
        });

        // 验证异常消息
        assertTrue(exception.getMessage().contains("已审批"));
    }

    @Test
    @DisplayName("测试审批不存在的卡片-应抛出异常")
    void testAuditNonExistentCard() {
        // 模拟getById返回null
        doReturn(null).when(cardService).getById(999L);

        // 设置auditDTO使用不存在的ID
        auditDTO.setCardId(999L);

        // 执行审批，期望抛出异常
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            cardService.auditCard(auditDTO);
        });

        // 验证异常消息
        assertTrue(exception.getMessage().contains("不存在"));
    }

    @Test
    @DisplayName("测试用户修改自己的卡片-待审批状态")
    void testUpdateMyCardPending() {
        // 模拟getById返回待审批卡片
        doReturn(testCard).when(cardService).getById(1L);
        doReturn(true).when(cardService).updateById(any(BizCard.class));
        doNothing().when(cardTagService).setCardTags(anyLong(), anyList());

        // 执行修改
        createDTO.setTagIds(Arrays.asList(1L, 2L, 3L));
        cardService.updateMyCard(1L, createDTO, 100L);

        // 验证更新被调用
        verify(cardService).updateById(any(BizCard.class));
        verify(cardTagService).setCardTags(eq(1L), eq(createDTO.getTagIds()));
    }

    @Test
    @DisplayName("测试用户修改自己的卡片-已通过状态应抛出异常")
    void testUpdateMyCardApproved() {
        // 模拟getById返回已通过卡片
        testCard.setAuditStatus("1");
        doReturn(testCard).when(cardService).getById(1L);

        // 执行修改，期望抛出异常
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            cardService.updateMyCard(1L, createDTO, 100L);
        });

        // 验证异常消息
        assertTrue(exception.getMessage().contains("待审批"));
    }

    @Test
    @DisplayName("测试用户修改他人卡片-应抛出异常")
    void testUpdateOtherUserCard() {
        // 模拟getById返回其他用户的卡片
        testCard.setCreateUserId(200L);
        doReturn(testCard).when(cardService).getById(1L);

        // 执行修改，期望抛出异常
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            cardService.updateMyCard(1L, createDTO, 100L);
        });

        // 验证异常消息
        assertTrue(exception.getMessage().contains("无权限"));
    }

    @Test
    @DisplayName("测试用户删除自己的卡片-待审批状态")
    void testDeleteMyCardPending() {
        // 模拟getById返回待审批卡片
        doReturn(testCard).when(cardService).getById(1L);
        doReturn(true).when(cardService).removeById(1L);
        
        // 模拟cardTagService.lambdaUpdate链式调用
        com.baomidou.mybatisplus.extension.conditions.update.LambdaUpdateChainWrapper<BizCardTag> mockUpdateWrapper =
            mock(com.baomidou.mybatisplus.extension.conditions.update.LambdaUpdateChainWrapper.class);
        when(cardTagService.lambdaUpdate()).thenReturn(mockUpdateWrapper);
        when(mockUpdateWrapper.eq(any(), anyLong())).thenReturn(mockUpdateWrapper);
        when(mockUpdateWrapper.remove()).thenReturn(true);

        // 执行删除
        cardService.deleteMyCard(1L, 100L);

        // 验证删除被调用
        verify(cardService).removeById(eq(1L));
    }

    @Test
    @DisplayName("测试用户删除自己的卡片-已通过状态应抛出异常")
    void testDeleteMyCardApproved() {
        // 模拟getById返回已通过卡片
        testCard.setAuditStatus("1");
        doReturn(testCard).when(cardService).getById(1L);

        // 执行删除，期望抛出异常
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            cardService.deleteMyCard(1L, 100L);
        });

        // 验证异常消息
        assertTrue(exception.getMessage().contains("待审批"));
    }

    @Test
    @DisplayName("测试用户删除他人卡片-应抛出异常")
    void testDeleteOtherUserCard() {
        // 模拟getById返回其他用户的卡片
        testCard.setCreateUserId(200L);
        doReturn(testCard).when(cardService).getById(1L);

        // 执行删除，期望抛出异常
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            cardService.deleteMyCard(1L, 100L);
        });

        // 验证异常消息
        assertTrue(exception.getMessage().contains("无权限"));
    }

    @Test
    @DisplayName("测试DTO字段验证")
    void testDTOFields() {
        // 测试CardCreateDTO
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

        // 测试CardAuditDTO
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
    @DisplayName("测试BizCard实体字段")
    void testBizCardEntityFields() {
        BizCard card = new BizCard();
        card.setCardId(1L);
        card.setSubjectId(1L);
        card.setFrontContent("问题");
        card.setBackContent("答案");
        card.setDifficultyLevel(3);
        card.setAuditStatus("0");
        card.setCreateUserId(100L);
        card.setAuditUserId(1L);
        card.setAuditTime(LocalDateTime.now());
        card.setAuditRemark("审批备注");

        assertEquals(1L, card.getCardId());
        assertEquals(1L, card.getSubjectId());
        assertEquals("问题", card.getFrontContent());
        assertEquals("答案", card.getBackContent());
        assertEquals(3, card.getDifficultyLevel());
        assertEquals("0", card.getAuditStatus());
        assertEquals(100L, card.getCreateUserId());
        assertEquals(1L, card.getAuditUserId());
        assertNotNull(card.getAuditTime());
        assertEquals("审批备注", card.getAuditRemark());
    }

    @Test
    @DisplayName("测试分页查询待审批卡片-空列表")
    void testPagePendingCardsEmpty() {
        // 创建模拟的Page对象
        Page<CardAuditVO> mockPage = new Page<>(1, 10);
        mockPage.setRecords(new ArrayList<>());
        mockPage.setTotal(0);

        // 模拟mapper调用
        when(cardMapper.selectPendingCards(any(Page.class), any())).thenReturn(mockPage);

        // 执行查询
        Page<CardAuditVO> result = cardService.pagePendingCards(null, 1, 10);

        // 验证结果
        assertNotNull(result);
        assertEquals(0, result.getTotal());
        assertTrue(result.getRecords().isEmpty());
    }

    @Test
    @DisplayName("测试分页查询我的卡片-空列表")
    void testPageMyCardsEmpty() {
        // 创建模拟的Page对象
        Page<MyCardVO> mockPage = new Page<>(1, 10);
        mockPage.setRecords(new ArrayList<>());
        mockPage.setTotal(0);

        // 模拟mapper调用
        when(cardMapper.selectMyCards(any(Page.class), eq(100L))).thenReturn(mockPage);

        // 执行查询
        Page<MyCardVO> result = cardService.pageMyCards(100L, 1, 10);

        // 验证结果
        assertNotNull(result);
        assertEquals(0, result.getTotal());
        assertTrue(result.getRecords().isEmpty());
    }
}