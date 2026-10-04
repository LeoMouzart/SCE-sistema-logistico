from django.db import models

from compras.models import PedidoCompra
from core.models import (
    Lote,
    Motorista,
    OrigemMaterial,
    Produto,
    Transportadora,
    Usuario,
)


class RecebimentoCarga(models.Model):
    id_recebimento = models.BigAutoField(primary_key=True)

    transportadora = models.ForeignKey(
        Transportadora,
        models.DO_NOTHING,
        db_column="id_transportadora",
    )

    motorista = models.ForeignKey(
        Motorista,
        models.DO_NOTHING,
        db_column="id_motorista",
        blank=True,
        null=True,
    )

    origem = models.ForeignKey(
        OrigemMaterial,
        models.DO_NOTHING,
        db_column="id_origem",
    )

    data_prevista = models.DateField(
        blank=True,
        null=True,
    )

    data_chegada = models.DateField()

    hora_chegada = models.TimeField(
        blank=True,
        null=True,
    )

    quantidade_pedidos_informada = models.IntegerField()

    total_m2_informado = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    valor_frete_total = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        blank=True,
        null=True,
    )

    data_pagamento_frete = models.DateField(
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    recebido_por = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="recebido_por",
    )

    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "recebimento_carga"

    def __str__(self):
        return f"Recebimento {self.id_recebimento} - " f"{self.data_chegada}"


class RecebimentoCargaCompra(models.Model):
    id_recebimento_compra = models.BigAutoField(primary_key=True)

    recebimento = models.ForeignKey(
        RecebimentoCarga,
        models.DO_NOTHING,
        db_column="id_recebimento",
    )

    pedido_compra = models.ForeignKey(
        PedidoCompra,
        models.DO_NOTHING,
        db_column="id_pedido_compra",
    )

    class Meta:
        managed = False
        db_table = "recebimento_carga_compra"

        unique_together = (("recebimento", "pedido_compra"),)

    def __str__(self):
        return (
            f"Recebimento {self.recebimento.id_recebimento} - "
            f"Compra {self.pedido_compra.id_pedido_compra}"
        )


class RecebimentoCargaItem(models.Model):
    id_recebimento_item = models.BigAutoField(primary_key=True)

    recebimento = models.ForeignKey(
        RecebimentoCarga,
        models.DO_NOTHING,
        db_column="id_recebimento",
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

    quantidade = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    quantidade_m2 = models.DecimalField(
        max_digits=12,
        decimal_places=3,
        blank=True,
        null=True,
    )

    valor_frete_rateado = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    class Meta:
        managed = False
        db_table = "recebimento_carga_item"

    def __str__(self):
        return (
            f"Recebimento {self.recebimento.id_recebimento} - " f"{self.produto.codigo}"
        )
