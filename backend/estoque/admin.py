from django.contrib import admin

from .models import (
    EstoqueSaldo,
    InventarioEstoque,
    InventarioItem,
    MovimentacaoEstoque,
    ReservaEstoque,
)


@admin.register(EstoqueSaldo)
class EstoqueSaldoAdmin(admin.ModelAdmin):
    list_display = (
        "id_estoque",
        "produto",
        "lote",
        "local",
        "classificacao",
        "quantidade",
        "updated_at",
    )

    search_fields = (
        "produto__codigo",
        "produto__descricao",
        "lote__numero_lote",
        "local__nome",
    )

    list_filter = (
        "local",
        "classificacao",
    )


@admin.register(MovimentacaoEstoque)
class MovimentacaoEstoqueAdmin(admin.ModelAdmin):
    list_display = (
        "id_movimentacao",
        "produto",
        "lote",
        "tipo_movimentacao",
        "quantidade",
        "local_origem",
        "local_destino",
        "pedido",
        "usuario",
        "data_hora",
    )

    search_fields = (
        "produto__codigo",
        "produto__descricao",
        "pedido__numero_linx",
        "usuario__nome",
    )

    list_filter = (
        "tipo_movimentacao",
        "local_origem",
        "local_destino",
        "data_hora",
    )


@admin.register(ReservaEstoque)
class ReservaEstoqueAdmin(admin.ModelAdmin):
    list_display = (
        "id_reserva",
        "pedido",
        "produto",
        "lote",
        "local",
        "quantidade_reservada",
        "status",
        "reservado_por",
        "reservado_em",
        "liberado_em",
    )

    search_fields = (
        "pedido__numero_linx",
        "produto__codigo",
        "produto__descricao",
        "reservado_por__nome",
    )

    list_filter = (
        "status",
        "local",
        "classificacao",
    )


@admin.register(InventarioEstoque)
class InventarioEstoqueAdmin(admin.ModelAdmin):
    list_display = (
        "id_inventario",
        "data_contagem",
        "local",
        "status",
        "iniciado_por",
        "conferido_por",
        "created_at",
        "finalizado_at",
    )

    search_fields = (
        "local__nome",
        "iniciado_por__nome",
        "conferido_por__nome",
    )

    list_filter = (
        "status",
        "local",
        "data_contagem",
    )


@admin.register(InventarioItem)
class InventarioItemAdmin(admin.ModelAdmin):
    list_display = (
        "id_inventario_item",
        "inventario",
        "produto",
        "lote",
        "classificacao",
        "quantidade_sistema",
        "quantidade_contada",
        "diferenca",
        "contado_em",
    )

    search_fields = (
        "produto__codigo",
        "produto__descricao",
        "lote__numero_lote",
    )

    list_filter = ("classificacao",)
