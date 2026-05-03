package com.card.learn.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.card.learn.entity.BizUserDevice;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 用户设备Mapper
 */
@Mapper
public interface BizUserDeviceMapper extends BaseMapper<BizUserDevice> {

    BizUserDevice selectByDeviceToken(@Param("deviceToken") String deviceToken);

}
