package com.card.learn.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.dto.AdminReviewPlanQueryDTO;
import com.card.learn.dto.DeviceRegisterDTO;
import com.card.learn.dto.SM2ReviewDTO;
import com.card.learn.vo.*;

import java.util.List;

/**
 * 学习服务接口（SM-2、复习计划、统计）
 */
public interface ILearningService {

    /**
     * 获取用户SM-2进度
     */
    SM2ProgressVO getSM2Progress(Long userId, Long cardId);

    /**
     * 提交复习结果
     */
    void submitReview(SM2ReviewDTO dto);

    /**
     * 获取复习计划
     */
    List<ReviewPlanVO> getReviewPlan(Long userId);

    /**
     * 获取科目进度（Java计算掌握度）
     */
    List<SubjectProgressVO> getSubjectProgress(Long userId);

    /**
     * 获取学习统计（Streak等）
     */
    UserStreakVO getLearningStats(Long userId);

    /**
     * 注册设备
     */
    void registerDevice(DeviceRegisterDTO dto);

    /**
     * 管理端：分页查询复习计划
     */
    Page<AdminReviewPlanVO> getAdminReviewPlan(AdminReviewPlanQueryDTO queryDTO);
}
