from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('repositorio.urls')),   # ← usa el nombre exacto de tu app: repositorio
]