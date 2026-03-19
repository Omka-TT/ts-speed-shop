from rest_framework import serializers

from apps.products.models import Product
from apps.products.serializers import ProductSerializer
from .models import Favorite


class FavoriteSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    product_id = serializers.PrimaryKeyRelatedField(
        queryset=Product.objects.all(),
        write_only=True,
        source="product",
    )

    class Meta:
        model = Favorite
        fields = ["id", "product", "product_id", "created_at"]
        read_only_fields = ["id", "product", "created_at"]

    def validate(self, attrs):
        request = self.context.get("request")
        product = attrs.get("product")
        if request and request.user.is_authenticated and product:
            if Favorite.objects.filter(user=request.user, product=product).exists():
                raise serializers.ValidationError({"detail": "Product already in favorites"})
        return attrs
