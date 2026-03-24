from rest_framework import serializers

from .models import Payment


class PaymentCreateSerializer(serializers.Serializer):
    order_id = serializers.IntegerField()
    payment_method = serializers.ChoiceField(choices=Payment.PAYMENT_METHOD_CHOICES)


class PaymentSerializer(serializers.ModelSerializer):

    class Meta:
        model = Payment
        fields = [
            "id",
            "order",
            "amount",
            "payment_method",
            "payment_status",
            "created_at",
        ]
        read_only_fields = [
            "id",
            "payment_status",
            "created_at",
        ]


