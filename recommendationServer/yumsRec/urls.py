from django.urls import include, path
from rest_framework import routers

from tutorial.quickstart import views

from django.urls import path
from recommendations.views import restaurant_recommendation_walk, restaurant_recommendation_vehicle

urlpatterns = [
    path('api/recommendation/v1/walk', restaurant_recommendation_walk, name='walk_recommendation'),
    path('api/recommendation/v1/vehicle', restaurant_recommendation_vehicle, name='vehicle_recommendation'),
]