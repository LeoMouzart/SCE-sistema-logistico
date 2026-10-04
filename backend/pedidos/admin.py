from django.contrib import admin

from .models import (
    Pedido,
    PedidoAlteracaoPrazo,
    PedidoItem,
    PedidoStatusHistorico,
    SolicitacaoEntregaParcial,
)


@admin.register(Pedido)
class PedidoAdmin(admin.ModelAdmin):
    list_display = (
        "id_pedido",
        "numero_linx",
        "cliente",
        "vendedor",
        "data_venda",
        "data_entrega_prevista",
        "status_atual",
        "nf_emitida",
    )

    search_fields = (
        "numero_linx",
        "cliente__nome_razao_social",
        "vendedor__nome",
        "numero_nf",
    )

    list_filter = (
        "status_atual",
        "nf_emitida",
        "data_venda",
        "data_entrega_prevista",
    )


@admin.register(PedidoItem)
class PedidoItemAdmin(admin.ModelAdmin):
    list_display = (
        "id_pedido_item",
        "pedido",
        "produto",
        "quantidade_solicitada",
        "quantidade_reservada",
        "quantidade_separada",
        "quantidade_entregue",
    )

    search_fields = (
        "pedido__numero_linx",
        "produto__codigo",
        "produto__descricao",
    )


@admin.register(PedidoStatusHistorico)
class PedidoStatusHistoricoAdmin(admin.ModelAdmin):
    list_display = (
        "id_historico",
        "pedido",
        "status_anterior",
        "status_novo",
        "usuario",
        "data_hora",
    )

    search_fields = (
        "pedido__numero_linx",
        "usuario__nome",
    )

    list_filter = ("status_novo",)


@admin.register(PedidoAlteracaoPrazo)
class PedidoAlteracaoPrazoAdmin(admin.ModelAdmin):
    list_display = (
        "id_alteracao",
        "pedido",
        "data_anterior",
        "nova_data",
        "usuario",
        "data_hora",
    )

    search_fields = (
        "pedido__numero_linx",
        "usuario__nome",
    )


@admin.register(SolicitacaoEntregaParcial)
class SolicitacaoEntregaParcialAdmin(admin.ModelAdmin):
    list_display = (
        "id_solicitacao",
        "pedido",
        "tipo_solicitante",
        "cliente",
        "vendedor",
        "solicitado_em",
        "registrado_por",
    )

    search_fields = (
        "pedido__numero_linx",
        "cliente__nome_razao_social",
        "vendedor__nome",
    )

    list_filter = ("tipo_solicitante",)
