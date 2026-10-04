from django.db import models

from core.models import Cliente, Produto, Usuario, Vendedor


class Pedido(models.Model):
    id_pedido = models.BigAutoField(primary_key=True)

    numero_linx = models.CharField(
        max_length=50,
        unique=True,
    )

    cliente = models.ForeignKey(
        Cliente,
        models.DO_NOTHING,
        db_column="id_cliente",
    )

    vendedor = models.ForeignKey(
        Vendedor,
        models.DO_NOTHING,
        db_column="id_vendedor",
    )

    data_venda = models.DateField()

    data_entrega_original = models.DateField()
    data_entrega_prevista = models.DateField()

    status_atual = models.CharField(max_length=40)

    nf_emitida = models.BooleanField()

    numero_nf = models.CharField(
        max_length=50,
        blank=True,
        null=True,
    )

    data_emissao_nf = models.DateField(
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
        db_column="created_by",
    )

    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "pedido"

    def __str__(self):
        return f"Pedido {self.numero_linx}"


class PedidoItem(models.Model):
    id_pedido_item = models.BigAutoField(primary_key=True)

    pedido = models.ForeignKey(
        Pedido,
        models.DO_NOTHING,
        db_column="id_pedido",
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

    quantidade_reservada = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    quantidade_separada = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    quantidade_entregue = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "pedido_item"

    def __str__(self):
        return f"{self.pedido.numero_linx} - " f"{self.produto.codigo}"


class PedidoStatusHistorico(models.Model):
    id_historico = models.BigAutoField(primary_key=True)

    pedido = models.ForeignKey(
        Pedido,
        models.DO_NOTHING,
        db_column="id_pedido",
    )

    status_anterior = models.CharField(
        max_length=40,
        blank=True,
        null=True,
    )

    status_novo = models.CharField(max_length=40)

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
        db_table = "pedido_status_historico"

    def __str__(self):
        return (
            f"{self.pedido.numero_linx}: "
            f"{self.status_anterior} -> {self.status_novo}"
        )


class PedidoAlteracaoPrazo(models.Model):
    id_alteracao = models.BigAutoField(primary_key=True)

    pedido = models.ForeignKey(
        Pedido,
        models.DO_NOTHING,
        db_column="id_pedido",
    )

    data_anterior = models.DateField()
    nova_data = models.DateField()

    justificativa = models.TextField()

    usuario = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="id_usuario",
    )

    data_hora = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "pedido_alteracao_prazo"

    def __str__(self):
        return (
            f"{self.pedido.numero_linx}: " f"{self.data_anterior} -> {self.nova_data}"
        )


class SolicitacaoEntregaParcial(models.Model):
    id_solicitacao = models.BigAutoField(primary_key=True)

    pedido = models.ForeignKey(
        Pedido,
        models.DO_NOTHING,
        db_column="id_pedido",
    )

    tipo_solicitante = models.CharField(max_length=20)

    cliente = models.ForeignKey(
        Cliente,
        models.DO_NOTHING,
        db_column="id_cliente",
        blank=True,
        null=True,
    )

    vendedor = models.ForeignKey(
        Vendedor,
        models.DO_NOTHING,
        db_column="id_vendedor",
        blank=True,
        null=True,
    )

    motivo = models.TextField(
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    solicitado_em = models.DateTimeField()

    registrado_por = models.ForeignKey(
        Usuario,
        models.DO_NOTHING,
        db_column="registrado_por",
    )

    class Meta:
        managed = False
        db_table = "solicitacao_entrega_parcial"

    def __str__(self):
        return f"Solicitação parcial - " f"Pedido {self.pedido.numero_linx}"
