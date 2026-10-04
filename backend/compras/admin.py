from django.contrib import admin

from .models import (
    NegociacaoPromotor,
    PedidoCompra,
    PedidoCompraItem,
    Promotor,
    SolicitacaoMaterial,
    SolicitacaoMaterialItem,
)


@admin.register(Promotor)
class PromotorAdmin(admin.ModelAdmin):
    list_display = (
        "id_promotor",
        "nome",
        "fabricante",
        "telefone",
        "email",
        "ativo",
    )

    search_fields = (
        "nome",
        "fabricante__nome",
        "email",
    )

    list_filter = (
        "ativo",
        "fabricante",
    )


@admin.register(NegociacaoPromotor)
class NegociacaoPromotorAdmin(admin.ModelAdmin):
    list_display = (
        "id_negociacao",
        "promotor",
        "produto",
        "valor_tabela_m2",
        "valor_negociado_m2",
        "percentual_desconto",
        "data_negociacao",
        "validade_ate",
        "registrado_por",
    )

    search_fields = (
        "promotor__nome",
        "produto__codigo",
        "produto__descricao",
        "registrado_por__nome",
    )

    list_filter = (
        "data_negociacao",
        "validade_ate",
    )


@admin.register(SolicitacaoMaterial)
class SolicitacaoMaterialAdmin(admin.ModelAdmin):
    list_display = (
        "id_solicitacao",
        "tipo_solicitacao",
        "pedido",
        "solicitado_por",
        "data_solicitacao",
        "status",
    )

    search_fields = (
        "pedido__numero_linx",
        "solicitado_por__nome",
    )

    list_filter = (
        "tipo_solicitacao",
        "status",
        "data_solicitacao",
    )


@admin.register(SolicitacaoMaterialItem)
class SolicitacaoMaterialItemAdmin(admin.ModelAdmin):
    list_display = (
        "id_solicitacao_item",
        "solicitacao",
        "produto",
        "quantidade_solicitada",
        "quantidade_aprovada",
    )

    search_fields = (
        "produto__codigo",
        "produto__descricao",
    )


@admin.register(PedidoCompra)
class PedidoCompraAdmin(admin.ModelAdmin):
    list_display = (
        "id_pedido_compra",
        "numero_pedido_fabrica",
        "fabricante",
        "promotor",
        "data_pedido",
        "data_prevista_disponibilidade",
        "data_prevista_coleta",
        "status",
        "valor_total",
        "criado_por",
    )

    search_fields = (
        "numero_pedido_fabrica",
        "fabricante__nome",
        "promotor__nome",
        "criado_por__nome",
    )

    list_filter = (
        "status",
        "fabricante",
        "data_pedido",
        "data_prevista_disponibilidade",
    )


@admin.register(PedidoCompraItem)
class PedidoCompraItemAdmin(admin.ModelAdmin):
    list_display = (
        "id_pedido_compra_item",
        "pedido_compra",
        "produto",
        "quantidade",
        "valor_unitario",
        "valor_total_item",
        "solicitacao_item",
    )

    search_fields = (
        "produto__codigo",
        "produto__descricao",
        "pedido_compra__numero_pedido_fabrica",
    )
