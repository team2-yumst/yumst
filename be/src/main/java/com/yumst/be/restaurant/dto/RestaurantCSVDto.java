package com.yumst.be.restaurant.dto;

import lombok.Data;

@Data
public class RestaurantCSVDto {

    private String restaurantId; // yumst에서 사용하는 음식점식별번호

    // 공통 필드
    private String id; // 번호
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

    // 추가 필드 (관광식당, 관광 유흥음식점, 외국인전용유흥음식점)
    private String culturalBusinessTypeName; // 문화체육업종명
    private String culturalBusinessClassification; // 문화사업자구분명
    private String regionClassification; // 지역구분명
    private String totalFloors; // 총층수
    private String surroundingEnvironment; // 주변환경명
    private String productDescription; // 제작취급품목내용
    private String insuranceInstitution; // 보험기관명
    private String buildingUsage; // 건물용도명
    private String aboveGroundFloors; // 지상층수
    private String undergroundFloors; // 지하층수
    private String numberOfRooms; // 객실수
    private String totalBuildingArea; // 건축연면적
    private String englishBusinessName; // 영문상호명
    private String englishAddress; // 영문상호주소
    private String shipTotalTonnage; // 선박총톤수
    private String numberOfShips; // 선박척수
    private String shipSpecifications; // 선박제원
    private String stageArea; // 무대면적
    private String seatingCapacity; // 좌석수
    private String souvenirTypes; // 기념품종류
    private String conferenceCapacity; // 회의실별동시수용인원
    private String facilityArea; // 시설면적
    private String amusementRideDetails; // 놀이기구수내역
    private String numberOfPlayFacilities; // 놀이시설수
    private String hasBroadcastingFacilities; // 방송시설유무
    private String hasPowerGenerationFacilities; // 발전시설유무
    private String hasMedicalOffice; // 의무실유무
    private String hasInformationDesk; // 안내소유무
    private String travelInsuranceStartDate; // 기획여행보험시작일자
    private String travelInsuranceEndDate; // 기획여행보험종료일자
    private String capital; // 자본금
    private String insuranceStartDate; // 보험시작일자
    private String insuranceEndDate; // 보험종료일자
    private String ancillaryFacilities; // 부대시설내역
    private String facilityScale; // 시설규모

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
