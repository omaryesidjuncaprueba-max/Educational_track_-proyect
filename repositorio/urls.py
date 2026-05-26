from django.urls import path
from . import views

urlpatterns = [
    path('login/', views.login_view, name='login'),
    path('register/', views.register_view, name='register'),
    path('token/', views.obtener_token, name='token'),
    path('usuarios/', views.listar_usuarios, name='usuarios'),
    path('cambiar-rol/', views.cambiar_rol, name='cambiar_rol'),
    path('proyectos/', views.proyectos_list, name='proyectos'),
    path('proyectos/<int:pk>/calificar/', views.calificar_proyecto, name='calificar'),   # <- esta existe
    # path('proyectos/<int:pk>/calificar-simple/', views.calificar_proyecto_simple, name='calificar_simple'),  # <- elimina esta línea
    path('estadisticas/', views.estadisticas, name='estadisticas'),
    path('editar-perfil/', views.editar_perfil, name='editar_perfil'),
    path('proyectos/paginados/', views.proyectos_paginados, name='proyectos_paginados'),
    path('usuarios/paginados/', views.usuarios_paginados, name='usuarios_paginados'),
]