from django.urls import path

from .views import (
    alterar_status_pedido,
    alterar_status_reserva,
    criar_pedido,
    criar_reserva,
    detalhe_pedido,
    lista_pedidos,
)

app_name = "pedidos"


urlpatterns = [
    path(
        "",
        lista_pedidos,
        name="lista",
    ),
    path(
        "novo/",
        criar_pedido,
        name="criar",
    ),
    path(
        "<int:id_pedido>/reservar/",
        criar_reserva,
        name="criar_reserva",
    ),
    path(
        "<int:id_pedido>/reservas/<int:id_reserva>/<str:acao>/",
        alterar_status_reserva,
        name="alterar_status_reserva",
    ),
    path(
        "<int:id_pedido>/status/",
        alterar_status_pedido,
        name="alterar_status",
    ),
    path(
        "<int:id_pedido>/",
        detalhe_pedido,
        name="detalhe",
    ),
]
