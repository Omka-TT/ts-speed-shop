from django.urls import path
from .views import OrderDetailView, OrderListCreateView, PurchaseHistoryView

urlpatterns = [
    path('', OrderListCreateView.as_view(), name='order-list-create'),
    path('<int:pk>/', OrderDetailView.as_view(), name='order-detail'),
    path('purchase-history/', PurchaseHistoryView.as_view(), name='purchase-history'),
]


