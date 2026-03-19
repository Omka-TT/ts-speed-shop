from django.urls import path
from .views import (
    PaymentListCreateView,
    UploadPaymentScreenshotView,
    MyPaymentsView,
    ConfirmPaymentView,
)

urlpatterns = [
    path("", PaymentListCreateView.as_view(), name="payments-list-create"),

    path(
        "upload-screenshot/<int:payment_id>/",
        UploadPaymentScreenshotView.as_view(),
        name="upload-payment-screenshot"
    ),

    path(
        "my/",
        MyPaymentsView.as_view(),
        name="my-payments"
    ),

    path(
        "confirm/<int:payment_id>/",
        ConfirmPaymentView.as_view(),
        name="confirm-payment"
    ),
]