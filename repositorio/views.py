import json
from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.db.models import Q
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.authtoken.models import Token
from .models import Perfil, Proyecto, SolicitudCambioRol
from .serializers import ProyectoSerializer, UserSerializer, SolicitudCambioRolSerializer
from .permissions import EsCoordinador, EsLider, EsDocenteOLider

# ========================
# LOGIN TRADICIONAL (sesión por cookies)
# ========================
@csrf_exempt
@require_http_methods(["POST"])
def login_view(request):
    try:
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            perfil = Perfil.objects.get(user=user)
            return JsonResponse({
                'success': True,
                'username': user.username,
                'rol': perfil.rol,
                'id': user.id
            }, status=200)
        else:
            return JsonResponse({'error': 'Credenciales inválidas'}, status=401)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

# ========================
# REGISTRO DE USUARIO
# ========================
@csrf_exempt
@require_http_methods(["POST"])
def register_view(request):
    try:
        data = json.loads(request.body)
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')
        if not all([username, email, password]):
            return JsonResponse({'error': 'Faltan campos requeridos'}, status=400)
        if User.objects.filter(username=username).exists():
            return JsonResponse({'error': 'Nombre de usuario ya existe'}, status=400)
        if User.objects.filter(email=email).exists():
            return JsonResponse({'error': 'Correo ya registrado'}, status=400)
        user = User.objects.create_user(username=username, email=email, password=password)
        perfil, _ = Perfil.objects.get_or_create(user=user)
        return JsonResponse({
            'success': True,
            'message': 'Usuario creado exitosamente',
            'username': user.username,
            'rol': perfil.rol,
            'id': user.id
        }, status=201)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

# ========================
# OBTENER TOKEN (para autenticación desde Flutter)
# ========================
@api_view(['POST'])
@permission_classes([AllowAny])
def obtener_token(request):
    username = request.data.get('username')
    password = request.data.get('password')
    if not username or not password:
        return Response({'error': 'Faltan username o password'}, status=status.HTTP_400_BAD_REQUEST)
    user = authenticate(username=username, password=password)
    if not user:
        return Response({'error': 'Credenciales inválidas'}, status=status.HTTP_401_UNAUTHORIZED)
    token, _ = Token.objects.get_or_create(user=user)
    perfil, _ = Perfil.objects.get_or_create(user=user)
    return Response({
        'token': token.key,
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'rol': perfil.rol,
    })

# ========================
# VISTAS API (DRF)
# ========================
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def listar_usuarios(request):
    usuarios = User.objects.all()
    serializer = UserSerializer(usuarios, many=True)
    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAuthenticated, EsCoordinador])
def cambiar_rol(request):
    usuario_id = request.data.get('usuario_id')
    nuevo_rol = request.data.get('nuevo_rol')
    justificacion = request.data.get('justificacion')
    if not all([usuario_id, nuevo_rol, justificacion]):
        return Response({'error': 'Faltan datos'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        usuario = User.objects.get(id=usuario_id)
    except User.DoesNotExist:
        return Response({'error': 'Usuario no existe'}, status=status.HTTP_404_NOT_FOUND)
    solicitud = SolicitudCambioRol.objects.create(
        usuario=usuario,
        nuevo_rol=nuevo_rol,
        justificacion=justificacion,
        solicitado_por=request.user
    )
    serializer = SolicitudCambioRolSerializer(solicitud)
    return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
def proyectos_list(request):
    if request.method == 'GET':
        user = request.user
        rol = user.perfil.rol
        if rol == 'usuario_general':
            proyectos = Proyecto.objects.filter(
                Q(creado_por=user) | Q(estado='aprobado')
            )
        elif rol in ['docente', 'lider', 'coordinador']:
            proyectos = Proyecto.objects.all()
        else:
            proyectos = Proyecto.objects.none()
        serializer = ProyectoSerializer(proyectos, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        data = request.data
        try:
            proyecto = Proyecto.objects.create(
                titulo=data.get('titulo'),
                descripcion=data.get('descripcion'),
                creado_por=request.user,
                estado='pendiente',
                tipo=data.get('tipo', ''),
                categoria=data.get('categoria', '')
            )
            # Agregar autores (lista de correos)
            autores_emails = data.get('autores', [])
            for email in autores_emails:
                try:
                    autor = User.objects.get(email=email)
                    proyecto.autores.add(autor)
                except User.DoesNotExist:
                    pass
            proyecto.autores.add(request.user)
            return Response({'id': proyecto.id, 'message': 'Proyecto creado'}, status=201)
        except Exception as e:
            return Response({'error': str(e)}, status=400)

@api_view(['PATCH'])
@permission_classes([IsAuthenticated, EsLider])
def calificar_proyecto(request, pk):
    try:
        proyecto = Proyecto.objects.get(pk=pk)
    except Proyecto.DoesNotExist:
        return Response({'error': 'Proyecto no existe'}, status=status.HTTP_404_NOT_FOUND)
    estado = request.data.get('estado')
    calificacion = request.data.get('calificacion')
    comentario = request.data.get('comentario_revision', '')
    if estado in ['aprobado', 'rechazado']:
        proyecto.estado = estado
    if calificacion is not None:
        proyecto.calificacion = calificacion
    if comentario:
        proyecto.comentario_revision = comentario
    proyecto.save()
    serializer = ProyectoSerializer(proyecto)
    return Response(serializer.data)

# ========================
# ESTADÍSTICAS
# ========================
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def estadisticas(request):
    total = Proyecto.objects.count()
    pendientes = Proyecto.objects.filter(estado='pendiente').count()
    aprobados = Proyecto.objects.filter(estado='aprobado').count()
    rechazados = Proyecto.objects.filter(estado='rechazado').count()
    calificaciones = Proyecto.objects.filter(calificacion__isnull=False).values_list('calificacion', flat=True)
    promedio = sum(calificaciones) / len(calificaciones) if calificaciones else 0
    return Response({
        'total': total,
        'pendientes': pendientes,
        'aprobados': aprobados,
        'rechazados': rechazados,
        'promedio': round(promedio, 1)
    })

# ========================
# EDITAR PERFIL
# ========================
@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def editar_perfil(request):
    user = request.user
    perfil = user.perfil
    data = request.data
    nombre_completo = data.get('nombre_completo')
    if nombre_completo:
        perfil.nombre_completo = nombre_completo
        perfil.save()
    telefono = data.get('telefono')
    if telefono:
        perfil.telefono = telefono
        perfil.save()
    nueva_password = data.get('nueva_password')
    if nueva_password:
        user.set_password(nueva_password)
        user.save()
    email = data.get('email')
    if email and email != user.email:
        if User.objects.filter(email=email).exists():
            return Response({'error': 'El correo ya está registrado'}, status=400)
        user.email = email
        user.save()
    return Response({
        'message': 'Perfil actualizado correctamente',
        'username': user.username,
        'email': user.email,
        'nombre_completo': perfil.nombre_completo,
        'telefono': perfil.telefono,
        'rol': perfil.rol
    })

# ========================
# PAGINACIÓN (opcional)
# ========================
from rest_framework.pagination import PageNumberPagination

class PaginacionProyectos(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'
    max_page_size = 100

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def proyectos_paginados(request):
    user = request.user
    rol = user.perfil.rol
    if rol == 'usuario_general':
        queryset = Proyecto.objects.filter(Q(creado_por=user) | Q(estado='aprobado'))
    elif rol in ['docente', 'lider', 'coordinador']:
        queryset = Proyecto.objects.all()
    else:
        queryset = Proyecto.objects.none()
    paginator = PaginacionProyectos()
    page = paginator.paginate_queryset(queryset, request)
    serializer = ProyectoSerializer(page, many=True)
    return paginator.get_paginated_response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def usuarios_paginados(request):
    usuarios = User.objects.all()
    paginator = PaginacionProyectos()
    page = paginator.paginate_queryset(usuarios, request)
    serializer = UserSerializer(page, many=True)
    return paginator.get_paginated_response(serializer.data)