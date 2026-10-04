from django.contrib import admin

from .models import (
    AgendamentoEntrega,
    Entrega,
    EntregaItem,
    JustificativaEntrega,
)


@admin.register(AgendamentoEntrega)
class AgendamentoEntregaAdmin(admin.ModelAdmin):
    list_display = (
        "id_agendamento",
        "pedido",
        "data_agendada",
        "periodo",
        "agendado_por",
        "created_at",
    )

    search_fields = (
        "pedido__numero_linx",
        "agendado_por__nome",
    )

    list_filter = (
        "data_agendada",
        "periodo",
    )


@admin.register(Entrega)
class EntregaAdmin(admin.ModelAdmin):
    list_display = (
        "id_entrega",
        "pedido",
        "agendamento",
        "transportadora",
        "motorista",
        "data_saida",
        "hora_saida",
        "data_entrega",
        "hora_entrega",
        "status",
        "cidade",
        "regiao",
        "registrado_por",
    )

    search_fields = (
        "pedido__numero_linx",
        "transportadora__razao_social",
        "transportadora__nome_fantasia",
        "motorista__nome",
        "cidade",
        "regiao",
        "registrado_por__nome",
    )

    list_filter = (
        "status",
        "transportadora",
        "data_saida",
        "data_entrega",
    )


@admin.register(EntregaItem)
class EntregaItemAdmin(admin.ModelAdmin):
    list_display = (
        "id_entrega_item",
        "entrega",
        "pedido_item",
        "quantidade_entregue",
    )

    search_fields = (
        "entrega__pedido__numero_linx",
        "pedido_item__produto__codigo",
        "pedido_item__produto__descricao",
    )


@admin.register(JustificativaEntrega)
class JustificativaEntregaAdmin(admin.ModelAdmin):
    list_display = (
        "id_justificativa",
        "pedido",
        "entrega",
        "tipo",
        "justificativa",
        "registrado_por",
        "registrado_em",
    )

    search_fields = (
        "pedido__numero_linx",
        "justificativa",
        "registrado_por__nome",
    )

    list_filter = (
        "tipo",
        "registrado_em",
    )
