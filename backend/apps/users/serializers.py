from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import Profile

User = get_user_model()

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ("username", "email", "password")

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)


class ProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source="user.username")
    email = serializers.EmailField(source="user.email")

    class Meta:
        model = Profile
        fields = ["username", "email", "avatar"]

    def to_internal_value(self, data):
        """Handle nested user data during deserialization."""
        ret = super().to_internal_value(data)
        # Nest username and email under 'user' key for proper handling in update
        if 'username' in ret or 'email' in ret:
            ret['user'] = {
                'username': ret.pop('username', None),
                'email': ret.pop('email', None),
            }
            # Remove None values
            ret['user'] = {k: v for k, v in ret['user'].items() if v is not None}
        return ret

    def update(self, instance, validated_data):
        user_data = validated_data.pop("user", {})
        if user_data:
            user = instance.user
            if 'username' in user_data:
                user.username = user_data['username']
            if 'email' in user_data:
                user.email = user_data['email']
            user.save()
        
        if 'avatar' in validated_data:
            instance.avatar = validated_data['avatar']
        
        instance.save()
        return instance

