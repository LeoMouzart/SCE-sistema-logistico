from django.db import models

from core.models import Motorista, Transportadora, Usuario
from pedidos.models import Pedido, PedidoItem


class AgendamentoEntrega(models.Model):
    id_agendamento = models.BigAutoField(primary_key=True)

    pedido = models.ForeignKey(
        Pedido,
        models.DO_NOTHING,
        db_column="id_pedido",
    )

    data_agendada = models.DateField()

    periodo = models.CharField(
        max_length=20,
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    agendado_por = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="agendado_por",
    )

    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "agendamento_entrega"

    def __str__(self):
        return (
            f"Agendamento {self.id_agendamento} - " f"Pedido {self.pedido.numero_linx}"
        )


class Entrega(models.Model):
    id_entrega = models.BigAutoField(primary_key=True)

    pedido = models.ForeignKey(
        Pedido,
        models.DO_NOTHING,
        db_column="id_pedido",
    )

    agendamento = models.ForeignKey(
        AgendamentoEntrega,
        models.DO_NOTHING,
        db_column="id_agendamento",
        blank=True,
        null=True,
    )

    transportadora = models.ForeignKey(
        Transportadora,
        models.DO_NOTHING,
        db_column="id_transportadora",
        blank=True,
        null=True,
    )

    motorista = models.ForeignKey(
        Motorista,
        models.DO_NOTHING,
        db_column="id_motorista",
        blank=True,
        null=True,
    )

    data_saida = models.DateField(
        blank=True,
        null=True,
    )

    hora_saida = models.TimeField(
        blank=True,
        null=True,
    )

    data_entrega = models.DateField(
        blank=True,
        null=True,
    )

    hora_entrega = models.TimeField(
        blank=True,
        null=True,
    )

    status = models.CharField(max_length=30)

    cidade = models.CharField(
        max_length=100,
        blank=True,
        null=True,
    )

    regiao = models.CharField(
        max_length=100,
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
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "entrega"

    def __str__(self):
        return f"Entrega {self.id_entrega} - " f"Pedido {self.pedido.numero_linx}"


class EntregaItem(models.Model):
    id_entrega_item = models.BigAutoField(primary_key=True)

    entrega = models.ForeignKey(
        Entrega,
        models.DO_NOTHING,
        db_column="id_entrega",
    )

    pedido_item = models.ForeignKey(
        PedidoItem,
        models.DO_NOTHING,
        db_column="id_pedido_item",
    )

    quantidade_entregue = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    class Meta:
        managed = False
        db_table = "entrega_item"

    def __str__(self):
        return (
            f"Entrega {self.entrega.id_entrega} - "
            f"Item {self.pedido_item.id_pedido_item}"
        )


class JustificativaEntrega(models.Model):
    id_justificativa = models.BigAutoField(primary_key=True)

    pedido = models.ForeignKey(
        Pedido,
        models.DO_NOTHING,
        db_column="id_pedido",
    )

    entrega = models.ForeignKey(
        Entrega,
        models.DO_NOTHING,
        db_column="id_entrega",
        blank=True,
        null=True,
    )

    tipo = models.CharField(max_length=30)

    justificativa = models.TextField()

    registrado_por = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="registrado_por",
    )

    registrado_em = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "justificativa_entrega"

    def __str__(self):
        return f"{self.tipo} - " f"Pedido {self.pedido.numero_linx}"
