package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.card.learn.entity.BizFeedback;
import com.card.learn.vo.FeedbackVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 用户反馈Mapper
 */
@Mapper
public interface BizFeedbackMapper extends BaseMapper<BizFeedback> {

    /**
     * 分页查询反馈（关联用户和卡片信息）
     */
    Page<FeedbackVO> selectFeedbackWithDetails(Page<FeedbackVO> page,
            @Param("type") String type,
            @Param("status") String status);

    Page<BizFeedback> selectPageByUserId(Page<BizFeedback> page, @Param("userId") Long userId);

}