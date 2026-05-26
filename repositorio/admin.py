# repositorio/admin.py
from django.contrib import admin
from .models import Perfil, Proyecto, SolicitudCambioRol

admin.site.register(Perfil)
admin.site.register(Proyecto)
admin.site.register(SolicitudCambioRol)