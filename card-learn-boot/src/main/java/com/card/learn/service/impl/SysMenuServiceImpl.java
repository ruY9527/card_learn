package com.card.learn.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.card.learn.entity.SysMenu;
import com.card.learn.mapper.SysMenuMapper;
import com.card.learn.service.ISysMenuService;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 菜单Service实现
 */
@Service
public class SysMenuServiceImpl extends ServiceImpl<SysMenuMapper, SysMenu> implements ISysMenuService {

    @Override
    public List<SysMenu> selectMenusByUserId(Long userId) {
        return baseMapper.selectMenusByUserId(userId);
    }

    @Override
    public List<SysMenu> buildMenuTree(List<SysMenu> menus) {
        if (menus == null || menus.isEmpty()) {
            return new ArrayList<>();
        }
        Map<Long, List<SysMenu>> menuMap = menus.stream()
                .collect(Collectors.groupingBy(SysMenu::getParentId));
        menus.forEach(menu -> menu.setChildren(menuMap.get(menu.getMenuId())));
        return menus.stream()
                .filter(menu -> menu.getParentId() == 0L)
                .collect(Collectors.toList());
    }

    @Override
    public List<Long> selectMenuIdsByRoleId(Long roleId) {
        return baseMapper.selectMenuIdsByRoleId(roleId);
    }

}