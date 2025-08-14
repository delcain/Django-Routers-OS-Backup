from django.urls import path, include
from .views import upgrade_by_id

urlpatterns = [
    path('', upgrade_by_id, name='upgrade_by_id'),
]