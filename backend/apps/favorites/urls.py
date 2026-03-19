from django.urls import path

from .views import FavoriteDeleteView, FavoriteListCreateView


urlpatterns = [
    path("", FavoriteListCreateView.as_view(), name="favorites-list"),
    path("<int:pk>/", FavoriteDeleteView.as_view(), name="favorites-delete"),
]
