from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from apps.users.models import Profile

User = get_user_model()

class Command(BaseCommand):
    help = 'Create profiles for existing users who don\'t have one'

    def handle(self, *args, **options):
        users_without_profiles = User.objects.filter(profile__isnull=True)
        created_count = 0
        for user in users_without_profiles:
            Profile.objects.create(user=user)
            created_count += 1
            self.stdout.write(f'Created profile for user: {user.username}')
        self.stdout.write(self.style.SUCCESS(f'Successfully created {created_count} profiles'))