package com.yumst.be.restaurant.repository;

import com.yumst.be.restaurant.domain.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RestaurantRepository extends JpaRepository<Restaurant, Long> {
    List<Restaurant> findByAddressCity(String city);
    List<Restaurant> findByAddressGu(String gu);
    List<Restaurant> findByAddressDong(String dong);
    List<Restaurant> findByAddressStreet(String street);
    List<Restaurant> findByAddressStreetDetail(String streetDetail);
    List<Restaurant> findByAddressDongDetail(String dongDetail);
    List<Restaurant> findByAddressPostCode(String postCode);
    List<Restaurant> findByCategoryName(String name);
    List<Restaurant> findByOpenDataInformationName(String name);
    List<Restaurant> findByOpenDataInformationRating(Integer rating);
}
