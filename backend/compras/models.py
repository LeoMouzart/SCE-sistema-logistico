from django.db import models

from core.models import Fabricante, Produto, Usuario
from pedidos.models import Pedido


class Promotor(models.Model):
    id_promotor = models.BigAutoField(primary_key=True)

    fabricante = models.ForeignKey(
        Fabricante,
        models.DO_NOTHING,
        db_column="id_fabricante",
    )

    nome = models.CharField(max_length=150)

    telefone = models.CharField(
        max_length=30,
        blank=True,
        null=True,
    )

    email = models.CharField(
        max_length=150,
        blank=True,
        null=True,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "promotor"

    def __str__(self):
        return self.nome


class NegociacaoPromotor(models.Model):
    id_negociacao = models.BigAutoField(primary_key=True)

    promotor = models.ForeignKey(
        Promotor,
        models.DO_NOTHING,
        db_column="id_promotor",
    )

    produto = models.ForeignKey(
        Produto,
        models.DO_NOTHING,
        db_column="id_produto",
    )

    valor_tabela_m2 = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        blank=True,
        null=True,
    )

    valor_negociado_m2 = models.DecimalField(
        max_digits=12,
        decimal_places=2,
    )

    percentual_desconto = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        blank=True,
        null=True,
    )

    data_negociacao = models.DateField()

    validade_ate = models.DateField(
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    registrado_por = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="registrado_por",
    )

    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "negociacao_promotor"

    def __str__(self):
        return f"{self.promotor.nome} - " f"{self.produto.codigo}"


class SolicitacaoMaterial(models.Model):
    id_solicitacao = models.BigAutoField(primary_key=True)

    tipo_solicitacao = models.CharField(max_length=30)

    pedido = models.ForeignKey(
        Pedido,
        models.DO_NOTHING,
        db_column="id_pedido",
        blank=True,
        null=True,
    )

    solicitado_por = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="solicitado_por",
    )

    data_solicitacao = models.DateTimeField()

    status = models.CharField(max_length=30)

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    class Meta:
        managed = False
        db_table = "solicitacao_material"

    def __str__(self):
        return f"Solicitação {self.id_solicitacao} - {self.tipo_solicitacao}"


class SolicitacaoMaterialItem(models.Model):
    id_solicitacao_item = models.BigAutoField(primary_key=True)

    solicitacao = models.ForeignKey(
        SolicitacaoMaterial,
        models.DO_NOTHING,
        db_column="id_solicitacao",
    )

    produto = models.ForeignKey(
        Produto,
        models.DO_NOTHING,
        db_column="id_produto",
    )

    quantidade_solicitada = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    quantidade_aprovada = models.DecimalField(
        max_digits=12,
        decimal_places=3,
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    class Meta:
        managed = False
        db_table = "solicitacao_material_item"

    def __str__(self):
        return (
            f"Solicitação {self.solicitacao.id_solicitacao} - " f"{self.produto.codigo}"
        )


class PedidoCompra(models.Model):
    id_pedido_compra = models.BigAutoField(primary_key=True)

    fabricante = models.ForeignKey(
        Fabricante,
        models.DO_NOTHING,
        db_column="id_fabricante",
    )

    promotor = models.ForeignKey(
        Promotor,
        models.DO_NOTHING,
        db_column="id_promotor",
        blank=True,
        null=True,
    )

    negociacao = models.ForeignKey(
        NegociacaoPromotor,
        models.DO_NOTHING,
        db_column="id_negociacao",
        blank=True,
        null=True,
    )

    numero_pedido_fabrica = models.CharField(
        max_length=100,
        blank=True,
        null=True,
    )

    data_pedido = models.DateField()

    data_prevista_disponibilidade = models.DateField(
        blank=True,
        null=True,
    )

    data_prevista_coleta = models.DateField(
        blank=True,
        null=True,
    )

    status = models.CharField(max_length=30)

    valor_total = models.DecimalField(
        max_digits=14,
        decimal_places=2,
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    criado_por = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="criado_por",
    )

    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "pedido_compra"

    def __str__(self):
        numero = self.numero_pedido_fabrica or self.id_pedido_compra

        return f"Pedido de compra {numero}"


class PedidoCompraItem(models.Model):
    id_pedido_compra_item = models.BigAutoField(primary_key=True)

    pedido_compra = models.ForeignKey(
        PedidoCompra,
        models.DO_NOTHING,
        db_column="id_pedido_compra",
    )

    produto = models.ForeignKey(
        Produto,
        models.DO_NOTHING,
        db_column="id_produto",
    )

    quantidade = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    valor_unitario = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        blank=True,
        null=True,
    )

    valor_total_item = models.DecimalField(
        max_digits=14,
        decimal_places=2,
        blank=True,
        null=True,
    )

    solicitacao_item = models.ForeignKey(
        SolicitacaoMaterialItem,
        models.DO_NOTHING,
        db_column="id_solicitacao_item",
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    class Meta:
        managed = False
        db_table = "pedido_compra_item"

    def __str__(self):
        return (
            f"Compra {self.pedido_compra.id_pedido_compra} - " f"{self.produto.codigo}"
        )
