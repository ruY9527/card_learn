package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.entity.BizReviewPlan;
import com.card.learn.vo.AdminReviewPlanVO;
import com.card.learn.vo.ReviewPlanVO;
import com.card.learn.vo.SubjectMasteryVO;
import com.card.learn.vo.SubjectStatusCountVO;
import com.card.learn.vo.SubjectTotalVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;
import java.util.List;

/**
 * 复习计划Mapper
 */
@Mapper
public interface BizReviewPlanMapper extends BaseMapper<BizReviewPlan> {

    /**
     * 获取用户复习计划（带卡片信息）
     */
    List<ReviewPlanVO> selectReviewPlan(@Param("userId") Long userId, @Param("startDate") LocalDate startDate);

    /**
     * 管理端：分页查询所有用户的复习计划
     */
    Page<AdminReviewPlanVO> selectAdminReviewPlan(Page<AdminReviewPlanVO> page,
                                                    @Param("userId") Long userId,
                                                    @Param("status") String status,
                                                    @Param("scheduledDate") String scheduledDate);

    /**
     * 各科目卡片总数
     */
    List<SubjectTotalVO> selectSubjectCardTotals();

    /**
     * 各科目各状态进度数
     */
    List<SubjectStatusCountVO> selectSubjectStatusCounts(@Param("userId") Long userId);

    BizReviewPlan selectPendingByUserAndCard(@Param("userId") Long userId, @Param("cardId") Long cardId);

    BizReviewPlan selectLatestPendingByUserAndCard(@Param("userId") Long userId, @Param("cardId") Long cardId);
}
