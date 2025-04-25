from django.contrib import admin
from django.urls import path, include
from backup import urls
from django.conf.urls.static import static
from django.conf import settings
from django.conf.urls.i18n import i18n_patterns

urlpatterns = [
    path('', include('backup.urls')),
    path('admin/', admin.site.urls),
    path('i18n/', include('django.conf.urls.i18n')),
]

if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)