from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    # добавляем связанные имена для групп и разрешений, чтобы убрать конфликты
    groups = models.ManyToManyField(
        "auth.Group",
        related_name="custom_user_groups",  # уникальное имя
        blank=True,
        help_text="The groups this user belongs to.",
        verbose_name="groups",
    )
    user_permissions = models.ManyToManyField(
        "auth.Permission",
        related_name="custom_user_permissions",  # уникальное имя
        blank=True,
        help_text="Specific permissions for this user.",
        verbose_name="user permissions",
    )


class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    avatar = models.ImageField(upload_to="avatars/", null=True, blank=True)

    def __str__(self):
        return self.user.username