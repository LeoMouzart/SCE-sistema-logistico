from django.db import models
from django.contrib.auth.models import User
from django.db import models


class Cliente(models.Model):
    id_cliente = models.BigAutoField(primary_key=True)

    nome_razao_social = models.CharField(max_length=150)
    nome_fantasia = models.CharField(
        max_length=150,
        blank=True,
        null=True,
    )

    cpf_cnpj = models.CharField(
        max_length=20,
        blank=True,
        null=True,
    )

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

    cidade = models.CharField(
        max_length=100,
        blank=True,
        null=True,
    )

    estado = models.CharField(
        max_length=2,
        blank=True,
        null=True,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "cliente"

    def __str__(self):
        return self.nome_razao_social


class Vendedor(models.Model):
    id_vendedor = models.BigAutoField(primary_key=True)

    nome = models.CharField(max_length=150)

    email = models.CharField(
        max_length=150,
        blank=True,
        null=True,
    )

    telefone = models.CharField(
        max_length=30,
        blank=True,
        null=True,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "vendedor"

    def __str__(self):
        return self.nome


class Categoria(models.Model):
    id_categoria = models.BigAutoField(primary_key=True)

    nome = models.CharField(
        max_length=100,
        unique=True,
    )

    descricao = models.CharField(
        max_length=255,
        blank=True,
        null=True,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "categoria"

    def __str__(self):
        return self.nome


class Fabricante(models.Model):
    id_fabricante = models.BigAutoField(primary_key=True)

    nome = models.CharField(
        max_length=150,
        unique=True,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "fabricante"

    def __str__(self):
        return self.nome


class Produto(models.Model):
    id_produto = models.BigAutoField(primary_key=True)

    codigo = models.CharField(
        max_length=50,
        unique=True,
    )

    descricao = models.CharField(max_length=200)

    categoria = models.ForeignKey(
        Categoria,
        models.DO_NOTHING,
        db_column="id_categoria",
    )

    fabricante = models.ForeignKey(
        Fabricante,
        models.DO_NOTHING,
        db_column="id_fabricante",
        blank=True,
        null=True,
    )

    unidade_medida = models.CharField(max_length=20)

    estoque_minimo = models.DecimalField(
        max_digits=12,
        decimal_places=3,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "produto"

    def __str__(self):
        return f"{self.codigo} - {self.descricao}"


class Lote(models.Model):
    id_lote = models.BigAutoField(primary_key=True)

    produto = models.ForeignKey(
        Produto,
        models.DO_NOTHING,
        db_column="id_produto",
    )

    numero_lote = models.CharField(max_length=100)

    tonalidade = models.CharField(
        max_length=50,
        blank=True,
        null=True,
    )

    calibre = models.CharField(
        max_length=50,
        blank=True,
        null=True,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "lote"

        unique_together = (("produto", "numero_lote"),)

    def __str__(self):
        return f"{self.produto.codigo} - Lote {self.numero_lote}"


class OrigemMaterial(models.Model):
    id_origem = models.BigAutoField(primary_key=True)

    tipo_origem = models.CharField(max_length=30)

    nome = models.CharField(max_length=150)

    cidade = models.CharField(
        max_length=100,
        blank=True,
        null=True,
    )

    estado = models.CharField(
        max_length=2,
        blank=True,
        null=True,
    )

    observacao = models.TextField(
        blank=True,
        null=True,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "origem_material"

    def __str__(self):
        return self.nome


class Transportadora(models.Model):
    id_transportadora = models.BigAutoField(primary_key=True)

    razao_social = models.CharField(max_length=150)

    nome_fantasia = models.CharField(
        max_length=150,
        blank=True,
        null=True,
    )

    cnpj = models.CharField(
        max_length=20,
        blank=True,
        null=True,
    )

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

    contato = models.CharField(
        max_length=150,
        blank=True,
        null=True,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "transportadora"

    def __str__(self):
        return self.nome_fantasia or self.razao_social


class Motorista(models.Model):
    id_motorista = models.BigAutoField(primary_key=True)

    transportadora = models.ForeignKey(
        Transportadora,
        models.DO_NOTHING,
        db_column="id_transportadora",
        blank=True,
        null=True,
    )

    nome = models.CharField(max_length=150)

    cpf = models.CharField(
        max_length=20,
        blank=True,
        null=True,
    )

    telefone = models.CharField(
        max_length=30,
        blank=True,
        null=True,
    )

    cnh = models.CharField(
        max_length=30,
        blank=True,
        null=True,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "motorista"

    def __str__(self):
        return self.nome


class LocalEstoque(models.Model):
    id_local = models.BigAutoField(primary_key=True)

    nome = models.CharField(max_length=100)

    tipo_local = models.CharField(max_length=20)

    descricao = models.CharField(
        max_length=255,
        blank=True,
        null=True,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "local_estoque"

    def __str__(self):
        return self.nome


class ClassificacaoEstoque(models.Model):
    id_classificacao = models.BigAutoField(primary_key=True)

    nome = models.CharField(
        max_length=50,
        unique=True,
    )

    descricao = models.CharField(
        max_length=255,
        blank=True,
        null=True,
    )

    ativo = models.BooleanField()

    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "classificacao_estoque"

    def __str__(self):
        return self.nome


class Usuario(models.Model):
    id_usuario = models.BigAutoField(primary_key=True)

    auth_user = models.OneToOneField(
        User,
        models.DO_NOTHING,
        db_column="auth_user_id",
        blank=True,
        null=True,
    )

    nome = models.CharField(max_length=150)

    login = models.CharField(
        max_length=100,
        unique=True,
    )

    email = models.CharField(
        max_length=150,
        blank=True,
        null=True,
    )

    perfil = models.CharField(max_length=30)

    ativo = models.BooleanField()

    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = "usuario"

    def __str__(self):
        return self.nome
