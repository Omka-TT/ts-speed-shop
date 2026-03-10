from rest_framework import serializers
from .models import Payment


class PaymentCreateSerializer(serializers.ModelSerializer):

    class Meta:
        model = Payment
        fields = ["amount", "currency"]


class PaymentSerializer(serializers.ModelSerializer):

    class Meta:
        model = Payment
        fields = "__all__"
        read_only_fields = [
            "id",
            "status",
            "user",
            "created_at",
            "confirmed_at",
            "screenshot"
        ]


