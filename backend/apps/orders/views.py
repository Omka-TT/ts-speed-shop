from rest_framework import generics, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Order, OrderItem
from .serializers import OrderSerializer

class OrderListView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = OrderSerializer

    def get_queryset(self):
        return Order.objects.filter(user=self.request.user)

class OrderCreateView(generics.CreateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = OrderSerializer

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class CreateOrderView(APIView):

    permission_classes = [IsAuthenticated]

    def post(self, request):

        serializer = OrderSerializer(data=request.data)

        if serializer.is_valid():

            order = serializer.save(user=request.user)

            return Response(serializer.data)

        return Response(serializer.errors, status=400)
    



