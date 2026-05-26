from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db.models.signals import post_save
from django.dispatch import receiver

# ================= PERFIL DE USUARIO =================
class Perfil(models.Model):
    ROLES = (
        ('usuario_general', 'Usuario General'),
        ('docente', 'Docente'),
        ('lider', 'Líder'),
        ('coordinador', 'Coordinador'),
    )
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='perfil')
    rol = models.CharField(max_length=20, choices=ROLES, default='usuario_general')
    nombre_completo = models.CharField(max_length=100, blank=True)
    telefono = models.CharField(max_length=20, blank=True)

    def __str__(self):
        return f"{self.user.username} - {self.get_rol_display()}"


# ================= PROYECTO =================
class Proyecto(models.Model):
    ESTADOS = (
        ('pendiente', 'Pendiente'),
        ('aprobado', 'Aprobado'),
        ('rechazado', 'Rechazado'),
    )
    
    # Tipos de proyecto (3 opciones)
    TIPO_CHOICES = (
        ('Aprendizaje, conocimiento, tecnologías, comunicación y digitalización',
         'Aprendizaje, conocimiento, tecnologías, comunicación y digitalización'),
        ('Gestión, emprendimiento, organizaciones sociales del conocimiento y aprendizaje',
         'Gestión, emprendimiento, organizaciones sociales del conocimiento y aprendizaje'),
        ('Transmodernidad, naturaleza, ambiente, biodiversidad, ancestralidad y familia',
         'Transmodernidad, naturaleza, ambiente, biodiversidad, ancestralidad y familia'),
    )
    
    # Categorías (4 opciones)
    CATEGORIA_CHOICES = (
        ('Proyecto Tecnológico', 'Proyecto Tecnológico'),
        ('Proyecto de investigación', 'Proyecto de investigación'),
        ('Proyecto comunitario', 'Proyecto comunitario'),
        ('Proyecto de emprendimiento e innovación', 'Proyecto de emprendimiento e innovación'),
    )
    
    titulo = models.CharField(max_length=200)
    descripcion = models.TextField()
    autores = models.ManyToManyField(User, related_name='proyectos_autor')
    archivo = models.FileField(upload_to='proyectos/', blank=True, null=True)
    fecha_postulacion = models.DateTimeField(auto_now_add=True)
    estado = models.CharField(max_length=20, choices=ESTADOS, default='pendiente')
    calificacion = models.FloatField(null=True, blank=True, validators=[MinValueValidator(0), MaxValueValidator(5)])
    comentario_revision = models.TextField(blank=True)
    creado_por = models.ForeignKey(User, on_delete=models.CASCADE, related_name='proyectos_creados')
    tipo = models.CharField(max_length=200, choices=TIPO_CHOICES, default=TIPO_CHOICES[0][0])
    categoria = models.CharField(max_length=200, choices=CATEGORIA_CHOICES, default=CATEGORIA_CHOICES[0][0])

    def __str__(self):
        return self.titulo


# ================= HISTORIAL DEL PROYECTO (por semestre) =================
class HistorialProyecto(models.Model):
    proyecto = models.ForeignKey(Proyecto, on_delete=models.CASCADE, related_name='historial_proyectos')
    estado_anterior = models.CharField(max_length=20)
    estado_nuevo = models.CharField(max_length=20)
    calificacion = models.FloatField(null=True, blank=True)
    comentario = models.TextField(blank=True)
    fecha = models.DateTimeField(auto_now_add=True)
    semestre = models.CharField(max_length=20)  # Ej: "2025-1"
    realizado_por = models.ForeignKey(User, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.proyecto.titulo} - {self.fecha.strftime('%Y-%m-%d')}"


# ================= SOLICITUD DE CAMBIO DE ROL =================
class SolicitudCambioRol(models.Model):
    usuario = models.ForeignKey(User, on_delete=models.CASCADE, related_name='solicitudes_cambio_rol')
    nuevo_rol = models.CharField(max_length=20, choices=Perfil.ROLES)
    justificacion = models.TextField()
    solicitado_por = models.ForeignKey(User, on_delete=models.CASCADE, related_name='solicitudes_hechas')
    fecha = models.DateTimeField(auto_now_add=True)
    estado = models.CharField(max_length=20, default='pendiente')  # pendiente, aprobado, rechazado

    def __str__(self):
        return f"{self.usuario.username} → {self.nuevo_rol} ({self.estado})"


# ================= SEÑAL PARA CREAR PERFIL AUTOMÁTICAMENTE =================
@receiver(post_save, sender=User)
def crear_perfil_usuario(sender, instance, created, **kwargs):
    if created:
        Perfil.objects.create(user=instance)