from django.contrib import admin

from .models import (
    Categoria,
    ClassificacaoEstoque,
    Cliente,
    Fabricante,
    LocalEstoque,
    Lote,
    Motorista,
    OrigemMaterial,
    Produto,
    Transportadora,
    Usuario,
    Vendedor,
)


@admin.register(Cliente)
class ClienteAdmin(admin.ModelAdmin):
    list_display = (
        "id_cliente",
        "nome_razao_social",
        "nome_fantasia",
        "cidade",
        "estado",
        "ativo",
    )

    search_fields = (
        "nome_razao_social",
        "nome_fantasia",
        "cpf_cnpj",
    )

    list_filter = (
        "ativo",
        "estado",
    )


@admin.register(Vendedor)
class VendedorAdmin(admin.ModelAdmin):
    list_display = (
        "id_vendedor",
        "nome",
        "email",
        "telefone",
        "ativo",
    )

    search_fields = (
        "nome",
        "email",
    )

    list_filter = ("ativo",)


@admin.register(Categoria)
class CategoriaAdmin(admin.ModelAdmin):
    list_display = (
        "id_categoria",
        "nome",
        "ativo",
    )

    search_fields = ("nome",)

    list_filter = ("ativo",)


@admin.register(Fabricante)
class FabricanteAdmin(admin.ModelAdmin):
    list_display = (
        "id_fabricante",
        "nome",
        "ativo",
    )

    search_fields = ("nome",)

    list_filter = ("ativo",)


@admin.register(Produto)
class ProdutoAdmin(admin.ModelAdmin):
    list_display = (
        "id_produto",
        "codigo",
        "descricao",
        "categoria",
        "fabricante",
        "unidade_medida",
        "estoque_minimo",
        "ativo",
    )

    search_fields = (
        "codigo",
        "descricao",
    )

    list_filter = (
        "ativo",
        "categoria",
        "fabricante",
    )


@admin.register(Lote)
class LoteAdmin(admin.ModelAdmin):
    list_display = (
        "id_lote",
        "produto",
        "numero_lote",
        "tonalidade",
        "calibre",
        "ativo",
    )

    search_fields = (
        "numero_lote",
        "produto__codigo",
        "produto__descricao",
    )

    list_filter = ("ativo",)


@admin.register(OrigemMaterial)
class OrigemMaterialAdmin(admin.ModelAdmin):
    list_display = (
        "id_origem",
        "tipo_origem",
        "nome",
        "cidade",
        "estado",
        "ativo",
    )

    search_fields = ("nome",)

    list_filter = (
        "tipo_origem",
        "ativo",
    )


@admin.register(Transportadora)
class TransportadoraAdmin(admin.ModelAdmin):
    list_display = (
        "id_transportadora",
        "razao_social",
        "nome_fantasia",
        "cnpj",
        "telefone",
        "ativo",
    )

    search_fields = (
        "razao_social",
        "nome_fantasia",
        "cnpj",
    )

    list_filter = ("ativo",)


@admin.register(Motorista)
class MotoristaAdmin(admin.ModelAdmin):
    list_display = (
        "id_motorista",
        "nome",
        "transportadora",
        "cpf",
        "cnh",
        "ativo",
    )

    search_fields = (
        "nome",
        "cpf",
        "cnh",
    )

    list_filter = (
        "ativo",
        "transportadora",
    )


@admin.register(LocalEstoque)
class LocalEstoqueAdmin(admin.ModelAdmin):
    list_display = (
        "id_local",
        "nome",
        "tipo_local",
        "ativo",
    )

    search_fields = ("nome",)

    list_filter = (
        "tipo_local",
        "ativo",
    )


@admin.register(ClassificacaoEstoque)
class ClassificacaoEstoqueAdmin(admin.ModelAdmin):
    list_display = (
        "id_classificacao",
        "nome",
        "ativo",
    )

    search_fields = ("nome",)

    list_filter = ("ativo",)


@admin.register(Usuario)
class UsuarioAdmin(admin.ModelAdmin):
    list_display = (
        "id_usuario",
        "nome",
        "login",
        "perfil",
        "ativo",
        "auth_user",
    )

    search_fields = (
        "nome",
        "login",
        "email",
    )

    list_filter = (
        "perfil",
        "ativo",
    )
