from django.contrib import admin

from .models import (
    PesquisaNps,
    RespostaNps,
)


@admin.register(PesquisaNps)
class PesquisaNpsAdmin(admin.ModelAdmin):
    list_display = (
        "id_pesquisa",
        "pedido",
        "cliente",
        "status",
        "data_envio",
        "created_at",
    )

    search_fields = (
        "pedido__numero_linx",
        "cliente__nome_razao_social",
        "cliente__cpf_cnpj",
    )

    list_filter = (
        "status",
        "data_envio",
        "created_at",
    )


@admin.register(RespostaNps)
class RespostaNpsAdmin(admin.ModelAdmin):
    list_display = (
        "id_resposta",
        "pesquisa",
        "nome_respondente",
        "canal_resposta",
        "nota",
        "data_resposta",
    )

    search_fields = (
        "nome_respondente",
        "email_respondente",
        "telefone_respondente",
        "pesquisa__pedido__numero_linx",
    )

    list_filter = (
        "canal_resposta",
        "nota",
        "data_resposta",
    )
