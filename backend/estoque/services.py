from django.utils import timezone

from .models import ReservaEstoque


def expirar_reservas_vencidas():
    agora = timezone.now()

    return ReservaEstoque.objects.filter(
        status="ATIVA",
        expira_em__isnull=False,
        expira_em__lte=agora,
    ).update(
        status="EXPIRADA",
        liberado_em=agora,
    )
