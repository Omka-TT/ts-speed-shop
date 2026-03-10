from django.db import models
from django.conf import settings


class Payment(models.Model):

    STATUS_CHOICES = (
        ("PENDING", "Pending"),
        ("WAITING_CONFIRMATION", "Waiting confirmation"),
        ("COMPLETED", "Completed"),
        ("REJECTED", "Rejected"),
    )

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="payments"
    )

    amount = models.DecimalField(
        max_digits=10,
        decimal_places=2
    )

    currency = models.CharField(
        max_length=10,
        default="USD"
    )

    status = models.CharField(
        max_length=30,
        choices=STATUS_CHOICES,
        default="PENDING"
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