from django.db import models
from django.conf import settings

from apps.orders.models import Order


class Payment(models.Model):

    PAYMENT_METHOD_CARD = "card"
    PAYMENT_METHOD_CASH = "cash"
    PAYMENT_METHOD_PAYPAL = "paypal"

    PAYMENT_METHOD_CHOICES = [
        (PAYMENT_METHOD_CARD, "Card"),
        (PAYMENT_METHOD_CASH, "Cash"),
        (PAYMENT_METHOD_PAYPAL, "PayPal"),
    ]

    STATUS_PENDING = "pending"
    STATUS_COMPLETED = "completed"
    STATUS_FAILED = "failed"

    STATUS_CHOICES = [
        (STATUS_PENDING, "Pending"),
        (STATUS_COMPLETED, "Completed"),
        (STATUS_FAILED, "Failed"),
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="payments"
    )

    order = models.ForeignKey(
        Order,
        on_delete=models.CASCADE,
        related_name="payments",
        null=True,
        blank=True,
    )

    amount = models.DecimalField(
        max_digits=10,
        decimal_places=2
    )

    payment_method = models.CharField(
        max_length=20,
        choices=PAYMENT_METHOD_CHOICES,
        default=PAYMENT_METHOD_CARD,
    )

    currency = models.CharField(
        max_length=10,
        default="USD"
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default=STATUS_PENDING
    )

    screenshot = models.ImageField(
        upload_to="payments/screenshots/",
        null=True,
        blank=True
    )

    created_at = models.DateTimeField(auto_now_add=True)

    confirmed_at = models.DateTimeField(
        null=True,
        blank=True
    )

    def __str__(self):
        return f"Payment #{self.id} - {self.user}"