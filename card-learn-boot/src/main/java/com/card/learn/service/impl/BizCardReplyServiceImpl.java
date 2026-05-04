package com.card.learn.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.BizCardComment;
import com.card.learn.entity.BizCardReply;
import com.card.learn.entity.SysUser;
import com.card.learn.mapper.BizCardReplyMapper;
import com.card.learn.service.IBizCardCommentService;
import com.card.learn.service.IBizCardReplyService;
import com.card.learn.service.ISysUserService;
import com.card.learn.vo.ReplyVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 评论回复Service实现
 */
@Service
public class BizCardReplyServiceImpl extends ServiceImpl<BizCardReplyMapper, BizCardReply> implements IBizCardReplyService {

    @Autowired
    private BizCardReplyMapper replyMapper;

    @Autowired
    private IBizCardCommentService commentService;

    @Autowired
    private ISysUserService userService;

    @Override
    public Page<ReplyVO> pageReplies(Long commentId, Long userId, Integer pageNum, Integer pageSize) {
        Page<ReplyVO> page = new Page<>(pageNum, pageSize);
        return replyMapper.selectRepliesByCommentId(page, commentId, userId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public BizCardReply submitReply(BizCardReply reply) {
        // 从父评论获取card_id
        BizCardComment comment = commentService.getById(reply.getCommentId());
        if (comment == null) {
            throw new RuntimeException("评论不存在");
        }

        // 设置用户昵称
        if (reply.getUserNickname() == null || reply.getUserNickname().isEmpty()) {
            SysUser user = userService.getById(reply.getUserId());
            if (user != null) {
                reply.setUserNickname(user.getNickname() != null ? user.getNickname() : user.getUsername());
            }
        }

        reply.setCardId(comment.getCardId());
        reply.setStatus("0");
        reply.setLikeCount(0);
        reply.setDislikeCount(0);
        reply.setCreateBy(reply.getUserId());
        reply.setUpdateBy(reply.getUserId());
        save(reply);

        // 更新评论的回复数
        comment.setReplyCount((comment.getReplyCount() == null ? 0 : comment.getReplyCount()) + 1);
        commentService.updateById(comment);

        return reply;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteReply(Long replyId, Long userId) {
        BizCardReply reply = getById(replyId);
        if (reply != null && reply.getUserId().equals(userId)) {
            reply.setStatus("1");
            reply.setUpdateBy(userId);
            updateById(reply);

            // 更新评论的回复数
            BizCardComment comment = commentService.getById(reply.getCommentId());
            if (comment != null && comment.getReplyCount() != null && comment.getReplyCount() > 0) {
                comment.setReplyCount(comment.getReplyCount() - 1);
                commentService.updateById(comment);
            }
        }
    }

    @Override
    public List<ReplyVO> getChildrenReplies(Long parentReplyId, Long userId) {
        // 查询子回复
        LambdaQueryWrapper<BizCardReply> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BizCardReply::getParentReplyId, parentReplyId)
               .eq(BizCardReply::getStatus, "0")
               .orderByAsc(BizCardReply::getCreateTime);
        List<BizCardReply> replies = list(wrapper);

        // 批量查询用户昵称
        List<Long> userIds = replies.stream()
                .map(BizCardReply::getUserId)
                .distinct()
                .collect(Collectors.toList());

        Map<Long, String> nicknameMap = userIds.stream()
                .collect(Collectors.toMap(
                        uid -> uid,
                        uid -> {
                            SysUser user = userService.getById(uid);
                            if (user != null) {
                                return user.getNickname() != null ? user.getNickname() : user.getUsername();
                            }
                            return "匿名用户";
                        }
                ));

        // 转换为VO
        return replies.stream().map(r -> {
            ReplyVO vo = new ReplyVO();
            vo.setReplyId(r.getReplyId());
            vo.setCommentId(r.getCommentId());
            vo.setUserId(r.getUserId());
            vo.setUserNickname(r.getUserNickname() != null ? r.getUserNickname() : nicknameMap.getOrDefault(r.getUserId(), "匿名用户"));
            vo.setContent(r.getContent());
            vo.setLikeCount(r.getLikeCount());
            vo.setDislikeCount(r.getDislikeCount());
            vo.setParentReplyId(r.getParentReplyId());
            vo.setCreateTime(r.getCreateTime());
            vo.setHasMoreChildren(false);
            return vo;
        }).collect(Collectors.toList());
    }
}
