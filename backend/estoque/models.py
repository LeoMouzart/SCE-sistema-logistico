from django.db import models

from core.models import (
    ClassificacaoEstoque,
    LocalEstoque,
    Lote,
    Produto,
    Usuario,
)
from pedidos.models import Pedido, PedidoItem


class EstoqueSaldo(models.Model):
    id_estoque = models.BigAutoField(primary_key=True)

    produto = models.ForeignKey(
        Produto,
        models.DO_NOTHING,
        db_column="id_produto",
    )

    lote = models.ForeignKey(
        Lote,
        models.DO_NOTHING,
        db_column="id_lote",
        blank=True,
        null=True,
    )

    local = models.ForeignKey(
        LocalEstoque,
        models.DO_NOTHING,
        db_column="id_local",
    )

    classificacao = models.ForeignKey(
        ClassificacaoEstoque,
        models.DO_NOTHING,
        db_column="id_classificacao",
    )

    quantidade = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "estoque_saldo"

    def __str__(self):
        return f"{self.produto.codigo} - " f"{self.local.nome} - " f"{self.quantidade}"


class MovimentacaoEstoque(models.Model):
    id_movimentacao = models.BigAutoField(primary_key=True)

    produto = models.ForeignKey(
        Produto,
        models.DO_NOTHING,
        db_column="id_produto",
    )

    lote = models.ForeignKey(
        Lote,
        models.DO_NOTHING,
        db_column="id_lote",
        blank=True,
        null=True,
    )

    local_origem = models.ForeignKey(
        LocalEstoque,
        models.DO_NOTHING,
        db_column="id_local_origem",
        related_name="movimentacoes_origem",
        blank=True,
        null=True,
    )

    local_destino = models.ForeignKey(
        LocalEstoque,
        models.DO_NOTHING,
        db_column="id_local_destino",
        related_name="movimentacoes_destino",
        blank=True,
        null=True,
    )

    classificacao_origem = models.ForeignKey(
        ClassificacaoEstoque,
        models.DO_NOTHING,
        db_column="id_classificacao_origem",
        related_name="movimentacoes_classificacao_origem",
        blank=True,
        null=True,
    )

    classificacao_destino = models.ForeignKey(
        ClassificacaoEstoque,
        models.DO_NOTHING,
        db_column="id_classificacao_destino",
        related_name="movimentacoes_classificacao_destino",
        blank=True,
        null=True,
    )

    tipo_movimentacao = models.CharField(max_length=40)

    quantidade = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    pedido = models.ForeignKey(
        Pedido,
        models.DO_NOTHING,
        db_column="id_pedido",
        blank=True,
        null=True,
    )

    usuario = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="id_usuario",
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    data_hora = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "movimentacao_estoque"

    def __str__(self):
        return (
            f"{self.tipo_movimentacao} - "
            f"{self.produto.codigo} - "
            f"{self.quantidade}"
        )


class ReservaEstoque(models.Model):
    id_reserva = models.BigAutoField(primary_key=True)

    pedido = models.ForeignKey(
        Pedido,
        models.DO_NOTHING,
        db_column="id_pedido",
    )

    pedido_item = models.ForeignKey(
        PedidoItem,
        models.DO_NOTHING,
        db_column="id_pedido_item",
    )

    produto = models.ForeignKey(
        Produto,
        models.DO_NOTHING,
        db_column="id_produto",
    )

    lote = models.ForeignKey(
        Lote,
        models.DO_NOTHING,
        db_column="id_lote",
        blank=True,
        null=True,
    )

    local = models.ForeignKey(
        LocalEstoque,
        models.DO_NOTHING,
        db_column="id_local",
    )

    classificacao = models.ForeignKey(
        ClassificacaoEstoque,
        models.DO_NOTHING,
        db_column="id_classificacao",
    )

    quantidade_reservada = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    status = models.CharField(max_length=20)

    reservado_por = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="reservado_por",
    )

    reservado_em = models.DateTimeField()

    liberado_em = models.DateTimeField(
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    vendedor_solicitante = models.ForeignKey(
        "core.Vendedor",
        models.DO_NOTHING,
        db_column="id_vendedor_solicitante",
        blank=True,
        null=True,
    )

    expira_em = models.DateTimeField(
        blank=True,
        null=True,
    )

    class Meta:
        managed = False
        db_table = "reserva_estoque"

    def __str__(self):
        return f"Reserva {self.id_reserva} - " f"Pedido {self.pedido.numero_linx}"


class InventarioEstoque(models.Model):
    id_inventario = models.BigAutoField(primary_key=True)

    data_contagem = models.DateField()

    local = models.ForeignKey(
        LocalEstoque,
        models.DO_NOTHING,
        db_column="id_local",
    )

    status = models.CharField(max_length=20)

    iniciado_por = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="iniciado_por",
        related_name="inventarios_iniciados",
    )

    conferido_por = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="conferido_por",
        related_name="inventarios_conferidos",
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    created_at = models.DateTimeField()

    finalizado_at = models.DateTimeField(
        blank=True,
        null=True,
    )

    class Meta:
        managed = False
        db_table = "inventario_estoque"

    def __str__(self):
        return (
            f"Inventário {self.id_inventario} - "
            f"{self.local.nome} - "
            f"{self.data_contagem}"
        )


class InventarioItem(models.Model):
    id_inventario_item = models.BigAutoField(primary_key=True)

    inventario = models.ForeignKey(
        InventarioEstoque,
        models.DO_NOTHING,
        db_column="id_inventario",
    )

    produto = models.ForeignKey(
        Produto,
        models.DO_NOTHING,
        db_column="id_produto",
    )

    lote = models.ForeignKey(
        Lote,
        models.DO_NOTHING,
        db_column="id_lote",
        blank=True,
        null=True,
    )

    classificacao = models.ForeignKey(
        ClassificacaoEstoque,
        models.DO_NOTHING,
        db_column="id_classificacao",
    )

    quantidade_sistema = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    quantidade_contada = models.DecimalField(
        max_digits=12,
        decimal_places=3,
        blank=True,
        null=True,
    )

    diferenca = models.DecimalField(
        max_digits=12,
        decimal_places=3,
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    contado_em = models.DateTimeField(
        blank=True,
        null=True,
    )

    class Meta:
        managed = False
        db_table = "inventario_item"

    def __str__(self):
        return f"Inventário {self.inventario.id_inventario} - " f"{self.produto.codigo}"
