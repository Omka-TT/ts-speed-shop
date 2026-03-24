from rest_framework import generics
from .models import Product
from .serializers import ProductSerializer


class ProductListView(generics.ListAPIView):

    serializer_class = ProductSerializer

    def get_queryset(self):
        queryset = Product.objects.all()
        category = self.request.query_params.get("category")
        if category:
            queryset = queryset.filter(category__name=category)
        product_type = self.request.query_params.get("type")
        if product_type in [Product.TYPE_PRODUCT, Product.TYPE_COURSE]:
            queryset = queryset.filter(type=product_type)
        return queryset


class ProductDetailView(generics.RetrieveAPIView):

    queryset = Product.objects.all()

    serializer_class = ProductSerializer


class CourseListView(generics.ListAPIView):

    serializer_class = ProductSerializer
    queryset = Product.objects.filter(type=Product.TYPE_COURSE)
