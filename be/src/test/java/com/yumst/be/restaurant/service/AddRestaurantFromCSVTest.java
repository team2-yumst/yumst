package com.yumst.be.restaurant.service;

import com.yumst.be.restaurant.repository.RestaurantRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Arrays;

@SpringBootTest
@Transactional
class AddRestaurantFromCSVTest {

    private static final String CSV_A = "/Users/leo/Downloads/식당data/관광식당.csv";
    private static final String CSV_B = "/Users/leo/Downloads/식당data/관광유흥음식점업.csv";
    private static final String CSV_C = "/Users/leo/Downloads/식당data/외국인전용유흥음식점업.csv";
    private static final String CSV_D = "/Users/leo/Downloads/식당data/일반음식점.csv";
    private static final String CSV_E = "/Users/leo/Downloads/식당data/휴게음식점.csv";
    private static final int BATCH_SIZE = 1000;

    @Autowired
    private RestaurantRepository restaurantRepository;

    @BeforeEach
    void setUp() {
        restaurantRepository.deleteAll();
    }

    @Test
    @DisplayName("5개 파일 헤더 비교")
    void importCsvTest() throws IOException {
        String aline = null;
        String bline = null;
        String cline = null;
        String dline = null;
        String eline = null;

        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(CSV_A), "EUC-KR"))) {
            aline = br.readLine(); // 헤더 읽기
            System.out.println(aline);
        }
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(CSV_B), "EUC-KR"))) {
            bline = br.readLine(); // 헤더 읽기
            System.out.println(bline);
        }
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(CSV_C), "EUC-KR"))) {
            cline = br.readLine(); // 헤더 읽기
            System.out.println(cline);
        }
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(CSV_D), "EUC-KR"))) {
            dline = br.readLine(); // 헤더 읽기
            System.out.println(dline);
        }
         try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(CSV_E), "EUC-KR"))) {
            eline = br.readLine(); // 헤더 읽기
            System.out.println(eline);
        }

        // 공통 부분
        System.out.println("\n공통 부분");
        for (Object o : aline.split(",")) {
            if (bline.contains((String) o) && cline.contains((String) o) && dline.contains((String) o) && eline.contains((String) o)) {
                int i = Arrays.stream(aline.split(",")).toList().indexOf(o);
                System.out.println(o);
            }
        }
        // a, b, c만 존재
        System.out.println("\n관광식당, 관광 유흥음식점, 외국인전용유흥음식점만 존재");
        for (Object o : aline.split(",")) {
            if (bline.contains((String) o) && cline.contains((String) o) && !dline.contains((String) o) && !eline.contains((String) o)) {
                int i = Arrays.stream(aline.split(",")).toList().indexOf(o);
                System.out.println(o);
            }
        }
        // d, e만 존재
        System.out.println("\n일반음식점, 휴게음식점만 존재");
        for (Object o : dline.split(",")) {
            if (!bline.contains((String) o) && !cline.contains((String) o) && eline.contains((String) o)) {
                int i = Arrays.stream(dline.split(",")).toList().indexOf(o);
                System.out.println(o);
            }
        }
    }



}