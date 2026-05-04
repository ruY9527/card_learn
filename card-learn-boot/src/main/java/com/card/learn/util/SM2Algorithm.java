package com.card.learn.util;

/**
 * SM-2 间隔重复算法
 * 参考 iOS 端 SM2Algorithm.swift 实现，保持算法一致性
 */
public final class SM2Algorithm {

    private static final double MIN_EASE_FACTOR = 1.3;
    private static final double DEFAULT_EASE_FACTOR = 2.5;

    private SM2Algorithm() {
    }

    /**
     * SM-2 计算结果
     */
    public static class SM2Result {
        private final int interval;
        private final double easeFactor;
        private final int repetitions;

        public SM2Result(int interval, double easeFactor, int repetitions) {
            this.interval = interval;
            this.easeFactor = easeFactor;
            this.repetitions = repetitions;
        }

        public int getInterval() {
            return interval;
        }

        public double getEaseFactor() {
            return easeFactor;
        }

        public int getRepetitions() {
            return repetitions;
        }
    }

    /**
     * 计算 SM-2 下次复习参数
     *
     * @param quality        质量评分 (0-5)，0=完全忘记，5=完美记住
     * @param currentEF      当前容易系数
     * @param currentReps    当前连续正确次数
     * @param currentInterval 当前间隔天数
     * @return SM2Result 包含新的 interval、easeFactor、repetitions
     */
    public static SM2Result calculate(int quality, double currentEF, int currentReps, int currentInterval) {
        // 计算新的容易系数
        double q = quality;
        double newEF = currentEF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
        newEF = Math.max(MIN_EASE_FACTOR, newEF);

        int newInterval;
        int newReps;

        if (quality >= 3) {
            // 正确：根据连续正确次数计算间隔
            if (currentReps == 0) {
                newInterval = 1;
            } else if (currentReps == 1) {
                newInterval = 6;
            } else {
                newInterval = (int) Math.round(currentInterval * newEF);
            }
            newReps = currentReps + 1;
        } else {
            // 错误：重置
            newInterval = 1;
            newReps = 0;
        }

        return new SM2Result(newInterval, newEF, newReps);
    }

    /**
     * 获取默认的 SM-2 初始状态
     */
    public static SM2Result getDefaultResult() {
        return new SM2Result(1, DEFAULT_EASE_FACTOR, 0);
    }
}
