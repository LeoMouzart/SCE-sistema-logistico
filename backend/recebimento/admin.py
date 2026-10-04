from django.contrib import admin

from .models import (
    RecebimentoCarga,
    RecebimentoCargaCompra,
    RecebimentoCargaItem,
)


@admin.register(RecebimentoCarga)
class RecebimentoCargaAdmin(admin.ModelAdmin):
    list_display = (
        "id_recebimento",
        "transportadora",
        "motorista",
        "origem",
        "data_prevista",
        "data_chegada",
        "quantidade_pedidos_informada",
        "total_m2_informado",
        "valor_frete_total",
        "data_pagamento_frete",
        "recebido_por",
    )

    search_fields = (
        "transportadora__razao_social",
        "transportadora__nome_fantasia",
        "motorista__nome",
        "origem__nome",
        "recebido_por__nome",
    )

    list_filter = (
        "transportadora",
        "data_chegada",
        "data_pagamento_frete",
    )


@admin.register(RecebimentoCargaCompra)
class RecebimentoCargaCompraAdmin(admin.ModelAdmin):
    list_display = (
        "id_recebimento_compra",
        "recebimento",
        "pedido_compra",
    )

    search_fields = (
        "recebimento__id_recebimento",
        "pedido_compra__numero_pedido_fabrica",
        "pedido_compra__fabricante__nome",
    )


@admin.register(RecebimentoCargaItem)
class RecebimentoCargaItemAdmin(admin.ModelAdmin):
    list_display = (
        "id_recebimento_item",
        "recebimento",
        "produto",
        "lote",
        "quantidade",
        "quantidade_m2",
        "valor_frete_rateado",
    )

    search_fields = (
        "produto__codigo",
        "produto__descricao",
        "lote__numero_lote",
    )

    list_filter = ("produto",)
