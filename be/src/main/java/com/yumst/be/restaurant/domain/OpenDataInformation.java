package com.yumst.be.restaurant.domain;

import jakarta.persistence.Embeddable;
import lombok.Data;

@Embeddable
@Data
public class OpenDataInformation {

    private String serviceName; // 개방서비스명
    private String serviceId; // 개방서비스아이디
    private String municipalityCode; // 개방자치단체코드
    private String managementNumber; // 관리번호
    private String authorizationDate; // 인허가일자
    private String authorizationCancelDate; // 인허가취소일자
    private String businessStatusCode; // 영업상태구분코드
    private String businessStatusName; // 영업상태명
    private String detailedBusinessStatusCode; // 상세영업상태코드
    private String detailedBusinessStatusName; // 상세영업상태명
    private String closureDate; // 폐업일자
    private String suspensionStartDate; // 휴업시작일자
    private String suspensionEndDate; // 휴업종료일자
    private String reopeningDate; // 재개업일자
    private String contactNumber; // 소재지전화
    private String areaSize; // 소재지면적
    private String postalCode; // 소재지우편번호
    private String fullAddress; // 소재지전체주소
    private String roadNameFullAddress; // 도로명전체주소
    private String roadNamePostalCode; // 도로명우편번호
    private String businessName; // 사업장명
    private String lastModified; // 최종수정시점
    private String dataUpdateType; // 데이터갱신구분
    private String dataUpdateDate; // 데이터갱신일자
    private String businessTypeName; // 업태구분명
    private String coordinateX; // 좌표정보(x)
    private String coordinateY; // 좌표정보(y)

    // 추가 필드 (일반음식점, 휴게음식점)
    private String sanitationBusinessType; // 위생업태명
    private String numberOfMaleEmployees; // 남성종사자수
    private String numberOfFemaleEmployees; // 여성종사자수
    private String businessSurroundings; // 영업장주변구분명
    private String gradeClassification; // 등급구분명
    private String waterSupplyClassification; // 급수시설구분명
    private String totalEmployees; // 총직원수
    private String headOfficeEmployees; // 본사직원수
    private String factoryOfficeEmployees; // 공장사무직직원수
    private String factorySalesEmployees; // 공장판매직직원수
    private String factoryProductionEmployees; // 공장생산직직원수
    private String buildingOwnership; // 건물소유구분명
    private String deposit; // 보증액
    private String monthlyRent; // 월세액
    private String isMultiUseFacility; // 다중이용업소여부
    private String totalFacilityScale; // 시설총규모
    private String traditionalBusinessDesignationNumber; // 전통업소지정번호
    private String mainFoodOfTraditionalBusiness; // 전통업소주된음식
    private String website; // 홈페이지

}