package com.yumst.be.vote.dto;

import lombok.Data;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import org.hibernate.validator.constraints.Range;

@Data
public class RestaurantRequest {
    @NotNull(message = "Latitude is required")
    private Double latitude;
    
    @NotNull(message = "Longitude is required")
    private Double longitude;
    
    @NotNull(message = "Radius is required")
    @Range(min = 0, max = 10, message = "Radius must be between 0 and 10")
    private Double radius;
    
    private String sort;
    
    @Min(value = 0, message = "Page must be at least 0")
    private Integer page;
} 