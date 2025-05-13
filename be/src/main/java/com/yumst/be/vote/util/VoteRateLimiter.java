package com.yumst.be.vote.util;

import org.springframework.stereotype.Component;

import java.util.LinkedList;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class VoteRateLimiter {
    private final Map<String, Queue<Long>> userRequests = new ConcurrentHashMap<>();
    private static final int MAX_REQUESTS = 20;
    private static final long TIME_WINDOW_MS = 60 * 1000; // 1분
    
    public boolean allowRequest(String userId) {
        Queue<Long> requests = userRequests.computeIfAbsent(userId, k -> new LinkedList<>());
        long now = System.currentTimeMillis();
        
        // 요청 시간 큐에서 TIME_WINDOW_MS보다 오래된 요청 제거
        while (!requests.isEmpty() && requests.peek() < now - TIME_WINDOW_MS) {
            requests.poll();
        }
        
        if (requests.size() >= MAX_REQUESTS) {
            return false; // 제한 초과
        }
        
        requests.add(now);
        return true;
    }
} 