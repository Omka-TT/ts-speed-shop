from django.urls import path
from .views import (
    CreatePaymentView,
    UploadPaymentScreenshotView,
    MyPaymentsView,
    ConfirmPaymentView,
)

urlpatterns = [

    path(
        "create/",
        CreatePaymentView.as_view(),
        name="create-payment"
    ),

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