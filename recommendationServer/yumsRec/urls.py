from django.urls import path
from EquationRecommendations.views import restaurant_recommendation_walk, restaurant_recommendation_vehicle
from AIRecommendations.views import restaurant_recommendation_ai

urlpatterns = [
    path('api/recommendation/v1/walk', restaurant_recommendation_walk, name='walk_recommendation'),
    path('api/recommendation/v1/vehicle', restaurant_recommendation_vehicle, name='vehicle_recommendation'),
path('api/recommendation/v2/ai', restaurant_recommendation_ai, name='ai_recommendation')

]