package com.yumst.be.crawl.service;

import com.yumst.be.crawl.dto.CrawledNaverRestaurant;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.openqa.selenium.Keys.ENTER;

@Service
@Slf4j
@RequiredArgsConstructor
public class SeleniumService {

    public static final String BASE_URL = "https://map.naver.com/";
    // 검색창
    public static final String SEARCH_BOX_TAG = "div.input_box>input.input_search";
    // 검색 결과 frame 이름
    public static final String SEARCH_IFRAME = "iframe#searchIframe";
    public static final String ENTRY_IFRAME = "iframe#entryIframe";
    // 검색 결과에서 링크 a tag
    public static final String HREF_A_TAG = "a.P7gyV";
    public static final String HREF_A_TAG2 = "a.tzwk0";


    @Value("${chrome.driver.path}")
    private String chromeDriverPath;

    private WebDriver driver;
    private WebDriverWait wait;

    public CrawledNaverRestaurant crawl(String keyword, String location) {

        try {
            initDriver();
            search(keyword, location);
            switchIFrameAndClickRestaurant();

            // 검색 결과가 맞는지 확인
            validateCorrect();

            // 정보 추출
            String name = name();
            String category = category();
            Map<String, String> openHours = OpenHour();
            List<String> latitudeLongtitude = location();
            String phoneNumber = phoneNumber();
            String thumbNail = thumbNail();
            List<String> starsVisitorReviewCountBlogReviewCount = reviewAndRating();

            // 메뉴 상세

            // 리뷰 상세
            clickReviewTab();
            Map<String, String> featureAndCount = ReviewDetail();

            CrawledNaverRestaurant crawlResult = CrawledNaverRestaurant.builder()
                    .name(name)
                    .category(category)
                    .latitude(latitudeLongtitude.get(0))
                    .longitude(latitudeLongtitude.get(1))
                    .phoneNumber(phoneNumber)
                    .thumbnailUrl(thumbNail)
                    .mondayHours(openHours.get("월"))
                    .tuesdayHours(openHours.get("화"))
                    .wednesdayHours(openHours.get("수"))
                    .thursdayHours(openHours.get("목"))
                    .fridayHours(openHours.get("금"))
                    .saturdayHours(openHours.get("토"))
                    .sundayHours(openHours.get("일"))
                    .rating(starsVisitorReviewCountBlogReviewCount.get(0))
                    .visitorReviewCount(starsVisitorReviewCountBlogReviewCount.get(1))
                    .blogReviewCount(starsVisitorReviewCountBlogReviewCount.get(2))
                    .reviewFeatureMap(featureAndCount)
                    .build();


            log.debug("검색 완료");
            return crawlResult;

        } catch (Exception e) {
            log.error("error", e);
            return null;
        } finally {
            driver.quit();
        }
    }

    private void clickReviewTab() throws InterruptedException {

        List<WebElement> elements = driver.findElements(By.cssSelector("a.tpj9w._tab-menu"));

        for (WebElement element : elements) {
            if (element.getText().equals("리뷰")) {
                element.click();
                Thread.sleep(1000);
                element.sendKeys(ENTER);
            }
        }

        // 더보기 클릭
        wait.until(ExpectedConditions.elementToBeClickable(By.cssSelector("a.dP0sq"))).click();
        wait.until(ExpectedConditions.elementToBeClickable(By.cssSelector("a.dP0sq"))).click();
    }

    private Map<String, String> ReviewDetail() {

        Map<String, String> reviewDetail = new HashMap<>();

        List<WebElement> features = driver.findElements(By.cssSelector("span.t3JSf"));
        List<WebElement> featureCounts = driver.findElements(By.cssSelector("span.CUoLy"));

        for (int i = 0; i < features.size(); i++) {
            String feature = features.get(i).getText().replaceAll("\"", "");

            if (feature.isEmpty()) {
                continue;
            }

            String count = featureCounts.get(i).getText().split("\n")[1];
            log.debug("리뷰 특징: {}, 개수: {}", feature, count);
            reviewDetail.put(feature, count);
        }
        return reviewDetail;
    }

    private List<String> reviewAndRating() {

        List<String> result = new ArrayList<>();

        List<WebElement> reviews = driver.findElements(By.cssSelector(".dAsGb > span"));

        if (reviews.size() == 2) {
            result.add(null);
        }

        for (WebElement review : reviews) {
            String text = review.getText();

            if (text.startsWith("별점")) {
                String rating = text.split("\n")[1];
                log.debug("별점: {}", rating);
                result.add(rating);
            }

            if (text.startsWith("방문자")) {
                String reviewCount = text.split(" ")[2];
                log.debug("방문자 리뷰: {}", reviewCount);
                result.add(reviewCount);
            }

            if (text.startsWith("블로그")) {
                String reviewCount = text.split(" ")[2];
                log.debug("블로그 리뷰: {}", reviewCount);
                result.add(reviewCount);
            }
        }
        return result;
    }

    private String thumbNail() {
        String thumbnailUrl = driver.findElement(By.cssSelector("div.CEX4u > div.fNygA > a.place_thumb > img")).getAttribute("src");
        log.debug("thumbnail url: {}", thumbnailUrl);
        return thumbnailUrl;
    }

    private String phoneNumber() {
        try {
            String phoneNumber = driver.findElement(By.cssSelector("div.vV_z_ > span.xlx7Q")).getText();
            log.debug("phone number: {}", phoneNumber);
            return phoneNumber;
        } catch (Exception e) {
            // 전화번호는 중요하지 않아서 무시
            return null;
        }
    }


    private String name() {
        String name = driver.findElement(By.xpath("/html/body/div[3]/div/div/div/div[2]/div[1]/div[1]/div/span[1]")).getText();

        log.debug("이름: {}", name);
        return name;
    }

    private String category() {
        String category = driver.findElement(By.xpath("/html/body/div[3]/div/div/div/div[2]/div[1]/div[1]/div/span[2]")).getText();

        log.debug("카테고리: {}", category);
        return category;
    }

    private List<String> location() {
        WebElement scriptElement = driver.findElement(By.xpath("/html/body/script[6]"));
        String script = scriptElement.getAttribute("innerHTML");

        Pattern pattern = Pattern.compile("\"x\":\"([^\"]+)\",\\s*\"y\":\"([^\"]+)\"");
        Matcher matcher = pattern.matcher(script);

        if (matcher.find()) {
            String longitude = matcher.group(1);
            String latitude = matcher.group(2);
            log.debug("위도: {}, 경도: {}", latitude, longitude);

            return List.of(latitude, longitude);
        } else {
            log.debug("좌표를 찾을 수 없습니다.");
            return null;
        }
    }

    private Map<String, String> OpenHour() {

        Map<String, String> openHours = new HashMap<>();

        wait.until(ExpectedConditions.elementToBeClickable(By.cssSelector("a.gKP9i.RMgN0"))).click();

        List<WebElement> elements = driver.findElements(By.cssSelector("div.H3ua4"));

        if (elements.size() == 1) {
            String text = elements.getFirst().getText();
            log.debug("영업시간: {}", text);

            openHours.put("월", text);
            openHours.put("화", text);
            openHours.put("수", text);
            openHours.put("목", text);
            openHours.put("금", text);
            openHours.put("토", text);
            openHours.put("일", text);
        }

        if (elements.size() == 7) {
            List<WebElement> days = driver.findElements(By.cssSelector("span.i8cJw"));
            for (int i = 0; i < days.size(); i++) {
                String day = days.get(i).getText();
                String hour = elements.get(i).getText();
                log.debug("요일: {}, 시간: {}", day, hour);

                openHours.put(day, hour);
            }

        }

        return openHours;
    }

    private void validateCorrect() {

    }

    private void switchIFrameAndClickRestaurant() throws InterruptedException {

        if (!driver.findElements(By.cssSelector(ENTRY_IFRAME)).isEmpty()) {
            driver.switchTo().defaultContent();
            driver.switchTo().frame(driver.findElement(By.cssSelector("iframe#entryIframe")));
            return;
        }

        driver.switchTo().frame(driver.findElement(By.cssSelector(SEARCH_IFRAME)));


        List<WebElement> elements = driver.findElements(By.cssSelector(HREF_A_TAG));
        if (elements.isEmpty()) {
            elements = driver.findElements(By.cssSelector(HREF_A_TAG2));
        }

        log.debug("elements size: {}", elements.size());

        WebElement first = elements.getFirst();
        first.click();
        Thread.sleep(1000);
        first.sendKeys(ENTER);

        driver.switchTo().defaultContent();
        driver.switchTo().frame(driver.findElement(By.cssSelector("iframe#entryIframe")));
    }


    private void search(String keyword, String location) {
        WebElement searchBox = wait.until(
                ExpectedConditions.presenceOfElementLocated(By.cssSelector(SEARCH_BOX_TAG))
        );

        searchBox.sendKeys(keyword + " " + location);
        searchBox.sendKeys(ENTER);
    }

    private void initDriver() {
        System.setProperty("webdriver.chrome.driver", chromeDriverPath);

        ChromeOptions options = new ChromeOptions();
//            options.addArguments("headless");
        driver = new ChromeDriver(options);
        driver.get(BASE_URL);
        driver.manage().window().maximize();

        wait = new WebDriverWait(driver, Duration.ofSeconds(3));

        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(3));
    }





}
