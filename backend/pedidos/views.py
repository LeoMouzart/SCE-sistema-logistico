from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.core.paginator import Paginator
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone

from core.models import Usuario
from estoque.forms import ReservaEstoqueForm
from estoque.models import ReservaEstoque
from estoque.services import expirar_reservas_vencidas
from .forms import PedidoForm


from .models import (
    Pedido,
    PedidoItem,
    PedidoStatusHistorico,
)

# =========================================================
# CRIAR PEDIDO
# =========================================================


@login_required
def criar_pedido(request):

    usuario_operacional = Usuario.objects.filter(auth_user=request.user).first()

    if not usuario_operacional:

        messages.error(
            request,
            "Seu usuário não possui perfil operacional vinculado.",
        )

        return redirect("pedidos:lista")

    if request.method == "POST":

        form = PedidoForm(request.POST)

        if form.is_valid():

            pedido = form.save(commit=False)

            pedido.status_atual = "CADASTRADO"

            pedido.criado_por = usuario_operacional

            pedido.save()

            PedidoStatusHistorico.objects.create(
                pedido=pedido,
                status_anterior=None,
                status_novo="CADASTRADO",
                usuario=usuario_operacional,
                observacao="Pedido cadastrado no sistema.",
                data_hora=timezone.now(),
            )

            messages.success(
                request,
                "Pedido cadastrado com sucesso.",
            )

            return redirect(
                "pedidos:detalhe",
                id_pedido=pedido.id_pedido,
            )

    else:

        form = PedidoForm()

    context = {
        "form": form,
    }

    return render(
        request,
        "pedidos/form.html",
        context,
    )


@login_required
def lista_pedidos(request):

    # =========================
    # CONSULTA BASE
    # =========================

    pedidos_base = Pedido.objects.select_related(
        "cliente",
        "vendedor",
    ).order_by(
        "-data_venda",
        "-id_pedido",
    )

    # =========================
    # FILTROS RECEBIDOS
    # =========================

    busca = request.GET.get(
        "busca",
        "",
    ).strip()

    status = request.GET.get(
        "status",
        "",
    ).strip()

    cliente_id = request.GET.get(
        "cliente",
        "",
    ).strip()

    vendedor_id = request.GET.get(
        "vendedor",
        "",
    ).strip()

    data_inicio = request.GET.get(
        "data_inicio",
        "",
    ).strip()

    data_fim = request.GET.get(
        "data_fim",
        "",
    ).strip()

    # =========================
    # OPÇÕES DE STATUS
    # =========================

    status_opcoes = [
        {
            "valor": "CADASTRADO",
            "nome": "Cadastrado",
        },
        {
            "valor": "AGUARDANDO_MATERIAL",
            "nome": "Aguardando material",
        },
        {
            "valor": "COMPLETO",
            "nome": "Completo",
        },
        {
            "valor": "RESERVADO_COMPLETO",
            "nome": "Reserva completa",
        },
        {
            "valor": "RESERVADO_INCOMPLETO",
            "nome": "Reserva incompleta",
        },
        {
            "valor": "AGUARDANDO_ENTREGA",
            "nome": "Aguardando entrega",
        },
        {
            "valor": "EM_ENTREGA",
            "nome": "Em entrega",
        },
        {
            "valor": "ENTREGUE_PARCIAL",
            "nome": "Entregue parcial",
        },
        {
            "valor": "ENTREGUE",
            "nome": "Entregue",
        },
    ]

    # =========================
    # BUSCA POR PEDIDO
    # =========================

    if busca and busca.isdigit():

        pedidos_base = pedidos_base.filter(numero_linx=busca)

    # =========================
    # FILTRO POR STATUS
    # =========================

    if status:

        pedidos_base = pedidos_base.filter(status_atual=status)

    # =========================
    # FILTRO POR CLIENTE
    # =========================

    if cliente_id:

        pedidos_base = pedidos_base.filter(cliente_id=cliente_id)

    # =========================
    # FILTRO POR VENDEDOR
    # =========================

    if vendedor_id:

        pedidos_base = pedidos_base.filter(vendedor_id=vendedor_id)

    # =========================
    # FILTRO POR PERÍODO
    # =========================

    if data_inicio:

        pedidos_base = pedidos_base.filter(data_venda__gte=data_inicio)

    if data_fim:

        pedidos_base = pedidos_base.filter(data_venda__lte=data_fim)

    # =========================
    # OPÇÕES DOS FILTROS
    # =========================

    todos_pedidos = Pedido.objects.select_related(
        "cliente",
        "vendedor",
    ).all()

    clientes = {}
    vendedores = {}

    for pedido in todos_pedidos:

        if pedido.cliente:

            clientes[pedido.cliente_id] = pedido.cliente

        if pedido.vendedor:

            vendedores[pedido.vendedor_id] = pedido.vendedor

    # =========================
    # PAGINAÇÃO
    # =========================

    paginator = Paginator(
        pedidos_base,
        20,
    )

    numero_pagina = request.GET.get("page")

    pagina = paginator.get_page(numero_pagina)

    # =========================
    # CONTEXTO
    # =========================

    context = {
        "pagina": pagina,
        "clientes": clientes.values(),
        "vendedores": vendedores.values(),
        "status_opcoes": status_opcoes,
        "busca": busca,
        "status_selecionado": status,
        "cliente_selecionado": cliente_id,
        "vendedor_selecionado": vendedor_id,
        "data_inicio": data_inicio,
        "data_fim": data_fim,
    }

    return render(
        request,
        "pedidos/lista.html",
        context,
    )


# =========================================================
# DETALHE DO PEDIDO
# =========================================================


@login_required
def detalhe_pedido(request, id_pedido):

    # Atualiza reservas vencidas antes de exibir o pedido.
    expirar_reservas_vencidas()

    pedido = get_object_or_404(
        Pedido.objects.select_related(
            "cliente",
            "vendedor",
            "criado_por",
        ),
        id_pedido=id_pedido,
    )

    # =========================
    # ITENS
    # =========================

    itens = (
        PedidoItem.objects.filter(pedido=pedido)
        .select_related("produto")
        .order_by("id_pedido_item")
    )

    # =========================
    # HISTÓRICO
    # =========================

    historico = (
        PedidoStatusHistorico.objects.filter(pedido=pedido)
        .select_related("usuario")
        .order_by("-data_hora")
    )

    # =========================
    # RESERVAS
    # =========================

    reservas = (
        ReservaEstoque.objects.filter(pedido=pedido)
        .select_related(
            "pedido_item",
            "produto",
            "lote",
            "local",
            "classificacao",
            "reservado_por",
            "vendedor_solicitante",
        )
        .order_by("-reservado_em")
    )

    # =========================
    # CONTEXTO
    # =========================

    context = {
        "pedido": pedido,
        "itens": itens,
        "historico": historico,
        "reservas": reservas,
    }

    return render(
        request,
        "pedidos/detalhe.html",
        context,
    )


# =========================================================
# CRIAR RESERVA
# =========================================================


@login_required
def criar_reserva(request, id_pedido):

    expirar_reservas_vencidas()

    pedido = get_object_or_404(
        Pedido,
        id_pedido=id_pedido,
    )


@login_required
def alterar_status_pedido(request, id_pedido):

    pedido = get_object_or_404(
        Pedido,
        id_pedido=id_pedido,
    )

    usuario_operacional = Usuario.objects.filter(auth_user=request.user).first()

    if not usuario_operacional:

        messages.error(
            request,
            "Seu usuário não possui perfil operacional vinculado.",
        )

        return redirect(
            "pedidos:detalhe",
            id_pedido=pedido.id_pedido,
        )

    if request.method != "POST":

        return redirect(
            "pedidos:detalhe",
            id_pedido=pedido.id_pedido,
        )

    novo_status = request.POST.get(
        "novo_status",
        "",
    ).strip()

    observacao = request.POST.get(
        "observacao",
        "",
    ).strip()

    status_permitidos = [
        "CADASTRADO",
        "AGUARDANDO_MATERIAL",
        "COMPLETO",
        "RESERVADO_COMPLETO",
        "RESERVADO_INCOMPLETO",
        "AGUARDANDO_ENTREGA",
        "EM_ENTREGA",
        "ENTREGUE_PARCIAL",
        "ENTREGUE",
    ]

    if novo_status not in status_permitidos:

        messages.error(
            request,
            "Status inválido.",
        )

        return redirect(
            "pedidos:detalhe",
            id_pedido=pedido.id_pedido,
        )

    status_anterior = pedido.status_atual

    if novo_status == status_anterior:

        messages.warning(
            request,
            "O pedido já está nesse status.",
        )

        return redirect(
            "pedidos:detalhe",
            id_pedido=pedido.id_pedido,
        )

    pedido.status_atual = novo_status

    pedido.save(
        update_fields=[
            "status_atual",
            "updated_at",
        ]
    )

    PedidoStatusHistorico.objects.create(
        pedido=pedido,
        status_anterior=status_anterior,
        status_novo=novo_status,
        usuario=usuario_operacional,
        observacao=observacao or None,
        data_hora=timezone.now(),
    )

    messages.success(
        request,
        "Status do pedido atualizado com sucesso.",
    )

    return redirect(
        "pedidos:detalhe",
        id_pedido=pedido.id_pedido,
    )

    # =========================
    # USUÁRIO OPERACIONAL
    # =========================

    usuario_operacional = Usuario.objects.filter(auth_user=request.user).first()

    if not usuario_operacional:

        messages.error(
            request,
            "Seu usuário não possui perfil operacional vinculado.",
        )

        return redirect(
            "pedidos:detalhe",
            id_pedido=pedido.id_pedido,
        )

    # =========================
    # ENVIO DO FORMULÁRIO
    # =========================

    if request.method == "POST":

        form = ReservaEstoqueForm(
            request.POST,
            pedido=pedido,
        )

        if form.is_valid():

            reserva = form.save(commit=False)

            # Pedido da reserva
            reserva.pedido = pedido

            # Produto obtido pelo item do pedido
            reserva.produto = reserva.pedido_item.produto

            # Nova reserva começa ativa
            reserva.status = "ATIVA"

            # Usuário que registrou a reserva
            reserva.reservado_por = usuario_operacional

            # Momento do registro
            reserva.reservado_em = timezone.now()

            reserva.save()

            messages.success(
                request,
                "Reserva criada com sucesso.",
            )

            return redirect(
                "pedidos:detalhe",
                id_pedido=pedido.id_pedido,
            )

    # =========================
    # ABERTURA DO FORMULÁRIO
    # =========================

    else:

        form = ReservaEstoqueForm(
            pedido=pedido,
        )

    # =========================
    # CONTEXTO
    # =========================

    context = {
        "pedido": pedido,
        "form": form,
    }

    return render(
        request,
        "pedidos/reserva_form.html",
        context,
    )


@login_required
def alterar_status_reserva(request, id_pedido, id_reserva, acao):

    reserva = get_object_or_404(
        ReservaEstoque,
        id_reserva=id_reserva,
        pedido_id=id_pedido,
    )

    if request.method != "POST":
        return redirect(
            "pedidos:detalhe",
            id_pedido=id_pedido,
        )

    acoes_permitidas = {
        "liberar": "LIBERADA",
        "cancelar": "CANCELADA",
        "consumir": "CONSUMIDA",
    }

    novo_status = acoes_permitidas.get(acao)

    if not novo_status:

        messages.error(
            request,
            "Ação de reserva inválida.",
        )

        return redirect(
            "pedidos:detalhe",
            id_pedido=id_pedido,
        )

    if reserva.status != "ATIVA":

        messages.warning(
            request,
            "Somente reservas ativas podem ser alteradas.",
        )

        return redirect(
            "pedidos:detalhe",
            id_pedido=id_pedido,
        )

    reserva.status = novo_status

    if novo_status in (
        "LIBERADA",
        "CANCELADA",
    ):
        reserva.liberado_em = timezone.now()

    reserva.save(
        update_fields=[
            "status",
            "liberado_em",
        ]
    )

    messages.success(
        request,
        f"Reserva marcada como {novo_status.lower()}.",
    )

    return redirect(
        "pedidos:detalhe",
        id_pedido=id_pedido,
    )
