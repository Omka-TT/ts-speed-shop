from rest_framework import serializers

from apps.products.models import Product
from apps.products.serializers import ProductSerializer
from .models import CartItem


class CartItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    product_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = CartItem
        fields = ['id', 'product', 'product_id', 'quantity']
        read_only_fields = ['id', 'product']

    def validate_product_id(self, value):
        try:
            return Product.objects.get(pk=value)
        except Product.DoesNotExist:
            raise serializers.ValidationError("Product does not exist")

    def create(self, validated_data):
        user = self.context['request'].user
        product = validated_data.pop('product_id')
        quantity = validated_data.get('quantity', 1)

        existing_item = CartItem.objects.filter(user=user, product=product).first()
        if existing_item:
            existing_item.quantity += quantity
            existing_item.save()
            return existing_item

        return CartItem.objects.create(user=user, product=product, quantity=quantity)



