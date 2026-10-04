from django.db import models

from core.models import Cliente
from pedidos.models import Pedido


class PesquisaNps(models.Model):
    id_pesquisa = models.BigAutoField(primary_key=True)

    pedido = models.OneToOneField(
        Pedido,
        models.DO_NOTHING,
        db_column="id_pedido",
    )

    cliente = models.ForeignKey(
        Cliente,
        models.DO_NOTHING,
        db_column="id_cliente",
    )

    data_envio = models.DateTimeField(
        blank=True,
        null=True,
    )

    status = models.CharField(max_length=20)

    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "pesquisa_nps"

    def __str__(self):
        return f"NPS - Pedido {self.pedido.numero_linx}"


class RespostaNps(models.Model):
    id_resposta = models.BigAutoField(primary_key=True)

    pesquisa = models.OneToOneField(
        PesquisaNps,
        models.DO_NOTHING,
        db_column="id_pesquisa",
    )

    nome_respondente = models.CharField(
        max_length=150,
        blank=True,
        null=True,
    )

    email_respondente = models.CharField(
        max_length=150,
        blank=True,
        null=True,
    )

    telefone_respondente = models.CharField(
        max_length=30,
        blank=True,
        null=True,
    )

    canal_resposta = models.CharField(
        max_length=20,
        blank=True,
        null=True,
    )

    nota = models.IntegerField()

    comentario = models.TextField(
        blank=True,
        null=True,
    )

    data_resposta = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "resposta_nps"

    def __str__(self):
        return f"NPS {self.nota} - " f"Pedido {self.pesquisa.pedido.numero_linx}"
