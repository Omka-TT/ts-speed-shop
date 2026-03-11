from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static





urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/users/", include("apps.users.urls")),
    path("api/products/", include("apps.products.urls")),
    path("", include("apps.core.urls")),  # добавили корень
    path("api/cart/", include("apps.cart.urls")),
    path("api/orders/", include("apps.orders.urls")),
    path('accounts/', include('allauth.urls')),
    path('api/auth/', include('apps.accounts.urls')),
    path('api/auth/', include('dj_rest_auth.urls')),
    path('api/auth/registration/', include('dj_rest_auth.registration.urls')),
    path('api/payments/', include('apps.payments.urls')),

] 

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)


