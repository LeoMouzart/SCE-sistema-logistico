from datetime import timedelta

from django import forms
from django.db.models import Sum
from django.utils import timezone

from core.models import Vendedor

from .models import EstoqueSaldo, ReservaEstoque


class ReservaEstoqueForm(forms.ModelForm):

    vendedor_solicitante = forms.ModelChoiceField(
        queryset=Vendedor.objects.filter(ativo=True).order_by("nome"),
        required=True,
        label="Vendedor solicitante",
    )

    expira_em = forms.DateTimeField(
        required=True,
        label="Validade da reserva",
        widget=forms.DateTimeInput(
            attrs={
                "type": "datetime-local",
            },
            format="%Y-%m-%dT%H:%M",
        ),
        input_formats=[
            "%Y-%m-%dT%H:%M",
        ],
    )

    class Meta:
        model = ReservaEstoque

        fields = [
            "pedido_item",
            "lote",
            "local",
            "classificacao",
            "quantidade_reservada",
            "vendedor_solicitante",
            "expira_em",
            "observacao",
        ]

        widgets = {
            "observacao": forms.Textarea(
                attrs={
                    "rows": 3,
                    "placeholder": "Observação opcional",
                }
            ),
        }

    def __init__(self, *args, pedido=None, **kwargs):
        super().__init__(*args, **kwargs)

        self.pedido = pedido

        if pedido:
            self.fields["pedido_item"].queryset = pedido.pedidoitem_set.select_related(
                "produto"
            ).all()

        agora = timezone.localtime()

        self.fields["expira_em"].widget.attrs["min"] = agora.strftime("%Y-%m-%dT%H:%M")

        self.fields["expira_em"].widget.attrs["max"] = (
            agora + timedelta(days=7)
        ).strftime("%Y-%m-%dT%H:%M")

    def clean_quantidade_reservada(self):

        quantidade = self.cleaned_data["quantidade_reservada"]

        if quantidade <= 0:
            raise forms.ValidationError(
                "A quantidade reservada deve ser maior que zero."
            )

        return quantidade

    def clean_expira_em(self):

        expira_em = self.cleaned_data["expira_em"]

        agora = timezone.now()

        if expira_em <= agora:
            raise forms.ValidationError("A validade da reserva deve ser futura.")

        if expira_em > agora + timedelta(days=7):
            raise forms.ValidationError("O prazo máximo de uma reserva é de 7 dias.")

        return expira_em

    def clean(self):

        cleaned_data = super().clean()

        pedido_item = cleaned_data.get("pedido_item")

        lote = cleaned_data.get("lote")

        local = cleaned_data.get("local")

        classificacao = cleaned_data.get("classificacao")

        quantidade_reservada = cleaned_data.get("quantidade_reservada")

        if not all(
            [
                pedido_item,
                local,
                classificacao,
                quantidade_reservada,
            ]
        ):
            return cleaned_data

        produto = pedido_item.produto

        agora = timezone.now()

        # =========================
        # SALDO FÍSICO
        # =========================

        saldo_query = EstoqueSaldo.objects.filter(
            produto=produto,
            local=local,
            classificacao=classificacao,
        )

        if lote:

            saldo_query = saldo_query.filter(lote=lote)

        else:

            saldo_query = saldo_query.filter(lote__isnull=True)

        saldo_fisico = saldo_query.aggregate(total=Sum("quantidade"))["total"] or 0

        # =========================
        # RESERVAS ATIVAS
        # =========================

        reservas_query = ReservaEstoque.objects.filter(
            produto=produto,
            local=local,
            classificacao=classificacao,
            status="ATIVA",
            expira_em__gt=agora,
        )

        if lote:

            reservas_query = reservas_query.filter(lote=lote)

        else:

            reservas_query = reservas_query.filter(lote__isnull=True)

        total_reservado = (
            reservas_query.aggregate(total=Sum("quantidade_reservada"))["total"] or 0
        )

        # =========================
        # SALDO DISPONÍVEL
        # =========================

        saldo_disponivel = saldo_fisico - total_reservado

        # =========================
        # VALIDAÇÃO
        # =========================

        if quantidade_reservada > saldo_disponivel:

            raise forms.ValidationError(
                (
                    "Quantidade indisponível para reserva. "
                    f"Saldo disponível: {saldo_disponivel}."
                )
            )

        return cleaned_data
