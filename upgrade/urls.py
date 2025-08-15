from django.urls import path, include
from .views import upgrade_by_id, upgrade_home

urlpatterns = [
    path('', upgrade_home, name='upgrade_home'),
    path('<int:device_id>', upgrade_by_id, name='upgrade_by_id'),
]