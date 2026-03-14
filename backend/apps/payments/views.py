from urllib import request

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser, AllowAny
from rest_framework import status

from django.shortcuts import get_object_or_404
from django.utils import timezone

from .models import Payment
from .serializers import PaymentCreateSerializer, PaymentSerializer


class CreatePaymentView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):

        if not request.user.is_authenticated:
            return Response(
                {"detail": "Authentication credentials were not provided."},
                status=401
            )

        serializer = PaymentCreateSerializer(data=request.data)

        if serializer.is_valid():

            payment = serializer.save(user=request.user)

            return Response(
                {
                    "payment_id": payment.id,
                    "status": payment.status,
                    "message": "Transfer the money to the card and upload screenshot."
                },
                status=status.HTTP_201_CREATED
            )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UploadPaymentScreenshotView(APIView):
    permission_classes = [AllowAny]

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
        payment.status = "WAITING_CONFIRMATION"
        payment.save()

        return Response(
            {"message": "Screenshot uploaded. Waiting admin confirmation."}
        )


class MyPaymentsView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):

        payments = Payment.objects.filter(
            user=request.user
        ).order_by("-created_at")

        serializer = PaymentSerializer(payments, many=True)

        return Response(serializer.data)


class ConfirmPaymentView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, payment_id):

        payment = get_object_or_404(Payment, id=payment_id)

        payment.status = "COMPLETED"
        payment.confirmed_at = timezone.now()
        payment.save()

        return Response(
            {
                "message": "Payment confirmed",
                "payment_id": payment.id
            }
        )



    

    






