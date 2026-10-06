from django import forms

from .models import Pedido


class PedidoForm(forms.ModelForm):

    class Meta:
        model = Pedido

        fields = [
            "numero_linx",
            "cliente",
            "vendedor",
            "data_venda",
            "data_entrega_original",
            "data_entrega_prevista",
            "nf_emitida",
            "numero_nf",
            "data_emissao_nf",
            "observacao",
        ]

        widgets = {
            "numero_linx": forms.NumberInput(
                attrs={
                    "placeholder": "Número do pedido no Linx",
                }
            ),
            "data_venda": forms.DateInput(
                attrs={
                    "type": "date",
                }
            ),
            "data_entrega_original": forms.DateInput(
                attrs={
                    "type": "date",
                }
            ),
            "data_entrega_prevista": forms.DateInput(
                attrs={
                    "type": "date",
                }
            ),
            "nf_emitida": forms.CheckboxInput(),
            "numero_nf": forms.TextInput(
                attrs={
                    "placeholder": "Número da nota fiscal",
                }
            ),
            "data_emissao_nf": forms.DateInput(
                attrs={
                    "type": "date",
                }
            ),
            "observacao": forms.Textarea(
                attrs={
                    "rows": 4,
                    "placeholder": "Observações do pedido",
                }
            ),
        }

        labels = {
            "numero_linx": "Número Linx",
            "cliente": "Cliente",
            "vendedor": "Vendedor",
            "data_venda": "Data da venda",
            "data_entrega_original": "Entrega original",
            "data_entrega_prevista": "Entrega prevista",
            "nf_emitida": "Nota fiscal emitida",
            "numero_nf": "Número da NF",
            "data_emissao_nf": "Data de emissão da NF",
            "observacao": "Observações",
        }

    def clean(self):

        cleaned_data = super().clean()

        nf_emitida = cleaned_data.get("nf_emitida")

        numero_nf = cleaned_data.get("numero_nf")

        data_emissao_nf = cleaned_data.get("data_emissao_nf")

        if nf_emitida:

            if not numero_nf:
                self.add_error(
                    "numero_nf",
                    "Informe o número da nota fiscal.",
                )

            if not data_emissao_nf:
                self.add_error(
                    "data_emissao_nf",
                    "Informe a data de emissão da nota fiscal.",
                )

        return cleaned_data
