package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;

/**
 * 后台用户Mapper
 */
@Mapper
public interface SysUserMapper extends BaseMapper<SysUser> {

}