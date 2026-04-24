package com.card.learn.controller;

import org.junit.jupiter.api.Test;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;

import java.lang.reflect.Method;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class PageRouteMappingTest {

    @Test
    void majorPageRouteShouldUseGetMapping() throws NoSuchMethodException {
        Method method = BizMajorController.class.getMethod(
                "page",
                String.class,
                String.class,
                Integer.class,
                Integer.class
        );

        GetMapping mapping = method.getAnnotation(GetMapping.class);
        assertNotNull(mapping);
        assertArrayEquals(new String[]{"/page"}, mapping.value());
    }

    @Test
    void majorDeleteRouteShouldOnlyMatchNumericIds() throws NoSuchMethodException {
        Method method = BizMajorController.class.getMethod("delete", Long.class);

        DeleteMapping mapping = method.getAnnotation(DeleteMapping.class);
        assertNotNull(mapping);
        assertArrayEquals(new String[]{"/{id:\\d+}"}, mapping.value());
    }

    @Test
    void subjectPageRouteShouldUseGetMapping() throws NoSuchMethodException {
        Method method = BizSubjectController.class.getMethod(
                "page",
                Long.class,
                String.class,
                Integer.class,
                Integer.class
        );

        GetMapping mapping = method.getAnnotation(GetMapping.class);
        assertNotNull(mapping);
        assertArrayEquals(new String[]{"/page"}, mapping.value());
    }

    @Test
    void subjectDeleteRouteShouldOnlyMatchNumericIds() throws NoSuchMethodException {
        Method method = BizSubjectController.class.getMethod("delete", Long.class);

        DeleteMapping mapping = method.getAnnotation(DeleteMapping.class);
        assertNotNull(mapping);
        assertArrayEquals(new String[]{"/{id:\\d+}"}, mapping.value());
    }
}
