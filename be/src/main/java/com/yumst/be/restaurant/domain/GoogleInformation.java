package com.yumst.be.restaurant.domain;

import jakarta.persistence.Embeddable;

@Embeddable
public class GoogleInformation {
    private Integer userRatingCount;
    private boolean takeOut;
    private boolean delivery;
    private boolean dineIn;
    private boolean curbsidePickup;
    private boolean reservable;
    private boolean servesBreakfast;
    private boolean servesLunch;
    private boolean servesDinner;
    private boolean servesBeer;
    private boolean servesWine;
    private boolean servesBrunch;
    private boolean servesVegetarianFood;
    private boolean outdoorSeating;
    private boolean liveMusic;
    private boolean menuForChildren;
    private boolean servesCocktails;
    private boolean servesDessert;
    private boolean servesCoffee;
    private boolean goodForChildren;
    private boolean allowsDogs;
    private boolean restroom;
    private boolean goodForGroups;
    private boolean goodForWatchingSports;
}
