from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Perfil, Proyecto, SolicitudCambioRol

class UserSerializer(serializers.ModelSerializer):
    rol = serializers.CharField(source='perfil.rol', read_only=True)
    nombre_completo = serializers.CharField(source='perfil.nombre_completo', required=False)
    telefono = serializers.CharField(source='perfil.telefono', required=False)

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'rol', 'nombre_completo', 'telefono']

class ProyectoSerializer(serializers.ModelSerializer):
    autores_nombres = serializers.StringRelatedField(source='autores', many=True, read_only=True)
    creado_por_nombre = serializers.StringRelatedField(source='creado_por', read_only=True)

    class Meta:
        model = Proyecto
        fields = '__all__'
        read_only_fields = ['fecha_postulacion', 'creado_por']

class SolicitudCambioRolSerializer(serializers.ModelSerializer):
    class Meta:
        model = SolicitudCambioRol
        fields = '__all__'
        read_only_fields = ['fecha', 'solicitado_por', 'estado']