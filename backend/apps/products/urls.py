from django.urls import path
from .views import CourseListView, ProductDetailView, ProductListView


urlpatterns = [

    path("", ProductListView.as_view()),

    path("courses/", CourseListView.as_view()),

    path("<int:pk>/", ProductDetailView.as_view()),

]