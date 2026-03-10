from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/users/", include("apps.users.urls")),
    path("api/products/", include("apps.products.urls")),
    path("", include("apps.core.urls")),  # добавили корень
    path("api/cart/", include("apps.cart.urls")),
    path("api/orders/", include("apps.orders.urls")),
    path('accounts/', include('allauth.urls')),
    path('api/auth/', include('apps.accounts.urls')),

]