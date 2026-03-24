from django.db import transaction
from django.utils import timezone

from rest_framework import generics, permissions, status
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.views import APIView

from django.shortcuts import get_object_or_404

from apps.orders.models import Order

from .models import Payment
from .serializers import PaymentCreateSerializer, PaymentSerializer


class PaymentListCreateView(generics.ListCreateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = PaymentSerializer

    def get_queryset(self):
        return Payment.objects.filter(user=self.request.user).order_by("-created_at")

    def create(self, request, *args, **kwargs):
        serializer = PaymentCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        order_id = serializer.validated_data["order_id"]
        payment_method = serializer.validated_data["payment_method"]

        try:
            order = Order.objects.get(id=order_id, user=request.user)
        except Order.DoesNotExist:
            raise ValidationError({"order_id": "Order not found."})

        if order.status != Order.STATUS_PENDING:
            raise ValidationError({"order_id": "Order is not pending."})

        with transaction.atomic():
            payment = Payment.objects.create(
                user=request.user,
                order=order,
                amount=order.total_price,
                payment_method=payment_method,
                payment_status=Payment.STATUS_COMPLETED,
            )

            order.status = Order.STATUS_PAID
            order.save(update_fields=["status"])

        out_serializer = PaymentSerializer(payment)
        return Response(out_serializer.data, status=status.HTTP_201_CREATED)


class UploadPaymentScreenshotView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, payment_id):
        payment = get_object_or_404(
            Payment,
            id=payment_id,
            user=request.user
        )

        screenshot = request.FILES.get("screenshot")
        if not screenshot:
            return Response(
                {"error": "Screenshot required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        payment.screenshot = screenshot
        payment.payment_status = Payment.STATUS_PENDING
        payment.save()

        return Response(
            {"message": "Screenshot uploaded. Waiting admin confirmation."}
        )


class MyPaymentsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        payments = Payment.objects.filter(
            user=request.user
        ).order_by("-created_at")

        serializer = PaymentSerializer(payments, many=True)
        return Response(serializer.data)


class ConfirmPaymentView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def post(self, request, payment_id):
        payment = get_object_or_404(Payment, id=payment_id)

        payment.payment_status = Payment.STATUS_COMPLETED
        payment.confirmed_at = timezone.now()
        payment.save()

        return Response(
            {
                "message": "Payment confirmed",
                "payment_id": payment.id
            }
        )



    

    






