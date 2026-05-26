from rest_framework import permissions

class EsCoordinador(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.perfil.rol == 'coordinador'

class EsLider(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.perfil.rol == 'lider'

class EsDocenteOLider(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.perfil.rol in ['docente', 'lider', 'coordinador']