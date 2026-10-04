from django.contrib.auth.decorators import login_required
from django.shortcuts import render
from django.utils import timezone
from django.db.models import Sum


from core.models import Cliente, Usuario
from estoque.models import EstoqueSaldo
from pedidos.models import Pedido
from nps.models import RespostaNps
from entregas.models import AgendamentoEntrega, Entrega
from entregas.models import AgendamentoEntrega, Entrega


@login_required
def dashboard(request):

    hoje = timezone.localdate()

    # =========================
    # USUÁRIO OPERACIONAL
    # =========================

    usuario_operacional = Usuario.objects.filter(auth_user=request.user).first()

    perfil = usuario_operacional.perfil if usuario_operacional else None

    pode_ver_faturamento = perfil in (
        "ADMIN",
        "GESTAO",
    )

    # =========================
    # PEDIDOS DO MÊS
    # =========================

    pedidos_mes_qs = Pedido.objects.filter(
        data_venda__year=hoje.year,
        data_venda__month=hoje.month,
    )

    pedidos_mes = pedidos_mes_qs.count()

    # =========================
    # STATUS DOS PEDIDOS
    # =========================

    status_entregues = pedidos_mes_qs.filter(status_atual="ENTREGUE").count()

    status_em_entrega = pedidos_mes_qs.filter(
        status_atual__in=[
            "EM_ENTREGA",
            "ENTREGUE_PARCIAL",
        ]
    ).count()

    status_aguardando_entrega = pedidos_mes_qs.filter(
        status_atual="AGUARDANDO_ENTREGA"
    ).count()

    status_aguardando_material = pedidos_mes_qs.filter(
        status_atual="AGUARDANDO_MATERIAL"
    ).count()

    status_preparacao = pedidos_mes_qs.filter(
        status_atual__in=[
            "CADASTRADO",
            "COMPLETO",
            "RESERVADO_COMPLETO",
            "RESERVADO_INCOMPLETO",
        ]
    ).count()

    pedidos_status_total = (
        status_entregues
        + status_em_entrega
        + status_aguardando_entrega
        + status_aguardando_material
        + status_preparacao
    )

    # =========================
    # PERCENTUAIS DO GRÁFICO
    # =========================

    def percentual(valor):
        if pedidos_status_total == 0:
            return 0

        return round(
            (valor / pedidos_status_total) * 100,
            2,
        )

    pct_entregues = percentual(status_entregues)

    pct_em_entrega = percentual(status_em_entrega)

    pct_aguardando_entrega = percentual(status_aguardando_entrega)

    pct_aguardando_material = percentual(status_aguardando_material)

    pct_preparacao = percentual(status_preparacao)

    # limites acumulados para o conic-gradient

    fim_entregues = pct_entregues

    fim_em_entrega = fim_entregues + pct_em_entrega

    fim_aguardando_entrega = fim_em_entrega + pct_aguardando_entrega

    fim_aguardando_material = fim_aguardando_entrega + pct_aguardando_material

    # =========================
    # PRODUTOS COM ESTOQUE
    # =========================

    produtos_estoque = (
        EstoqueSaldo.objects.filter(quantidade__gt=0)
        .values("produto_id")
        .distinct()
        .count()
    )

    # ESTOQUE EM DESTAQUE
    # =========================

    estoque_destaque_query = (
        EstoqueSaldo.objects.filter(quantidade__gt=0)
        .values(
            "produto_id",
            "produto__codigo",
            "produto__descricao",
            "produto__unidade_medida",
            "produto__estoque_minimo",
        )
        .annotate(quantidade_total=Sum("quantidade"))
        .order_by("quantidade_total")[:4]
    )

    estoque_destaque = []

    for item in estoque_destaque_query:

        estoque_minimo = item["produto__estoque_minimo"] or 0

        quantidade = item["quantidade_total"] or 0

        estoque_baixo = estoque_minimo > 0 and quantidade <= estoque_minimo

        estoque_destaque.append(
            {
                "id_produto": item["produto_id"],
                "codigo": item["produto__codigo"],
                "descricao": item["produto__descricao"],
                "unidade_medida": item["produto__unidade_medida"],
                "quantidade": quantidade,
                "estoque_minimo": estoque_minimo,
                "estoque_baixo": estoque_baixo,
            }
        )

    # =========================
    # ENTREGAS DE HOJE
    # =========================

    entregas_hoje = (
        Entrega.objects.filter(data_entrega=hoje)
        .select_related(
            "pedido",
            "transportadora",
            "motorista",
        )
        .order_by(
            "hora_entrega",
            "hora_saida",
        )[:5]
    )
    # =========================
    # NPS
    # =========================

    respostas_nps = RespostaNps.objects.all()

    total_respostas_nps = respostas_nps.count()

    promotores_nps = respostas_nps.filter(nota__gte=9).count()

    neutros_nps = respostas_nps.filter(
        nota__gte=7,
        nota__lte=8,
    ).count()

    detratores_nps = respostas_nps.filter(nota__lte=6).count()

    if total_respostas_nps > 0:

        pct_promotores_nps = round(
            (promotores_nps / total_respostas_nps) * 100,
            1,
        )

        pct_neutros_nps = round(
            (neutros_nps / total_respostas_nps) * 100,
            1,
        )

        pct_detratores_nps = round(
            (detratores_nps / total_respostas_nps) * 100,
            1,
        )

        nps_score = round(pct_promotores_nps - pct_detratores_nps)

    else:

        pct_promotores_nps = 0
        pct_neutros_nps = 0
        pct_detratores_nps = 0
        nps_score = 0

    # =========================
    # ALERTAS E PENDÊNCIAS
    # =========================
    # =========================
    # ATIVIDADES RECENTES
    # =========================

    atividades_recentes = []

    # -------------------------
    # ENTREGAS
    # -------------------------

    ultimas_entregas = Entrega.objects.select_related("pedido").order_by("-created_at")[
        :5
    ]

    for entrega in ultimas_entregas:

        atividades_recentes.append(
            {
                "tipo": "entrega",
                "titulo": "Entrega registrada",
                "descricao": (
                    f"Pedido {entrega.pedido_id} - " f"Status: {entrega.status}"
                ),
                "data": entrega.created_at,
            }
        )

    # -------------------------
    # AGENDAMENTOS
    # -------------------------

    ultimos_agendamentos = AgendamentoEntrega.objects.select_related("pedido").order_by(
        "-created_at"
    )[:5]

    for agendamento in ultimos_agendamentos:

        atividades_recentes.append(
            {
                "tipo": "agendamento",
                "titulo": "Entrega agendada",
                "descricao": (
                    f"Pedido {agendamento.pedido_id} - "
                    f"Data prevista: "
                    f"{agendamento.data_agendada.strftime('%d/%m/%Y')}"
                ),
                "data": agendamento.created_at,
            }
        )

    # -------------------------
    # ORDENAR ATIVIDADES
    # -------------------------

    atividades_recentes = sorted(
        atividades_recentes,
        key=lambda atividade: atividade["data"],
        reverse=True,
    )[:6]
    # -------------------------
    # ESTOQUE CRÍTICO
    # -------------------------

    estoque_por_produto = (
        EstoqueSaldo.objects.filter(quantidade__gt=0)
        .values(
            "produto_id",
            "produto__estoque_minimo",
        )
        .annotate(quantidade_total=Sum("quantidade"))
    )

    produtos_estoque_critico = 0

    for item in estoque_por_produto:

        estoque_minimo = item["produto__estoque_minimo"] or 0

        quantidade_total = item["quantidade_total"] or 0

        if estoque_minimo > 0 and quantidade_total <= estoque_minimo:
            produtos_estoque_critico += 1

    # -------------------------
    # PEDIDOS ATRASADOS
    # -------------------------

    pedidos_atrasados = (
        Pedido.objects.filter(
            data_entrega_prevista__lt=hoje,
        )
        .exclude(status_atual="ENTREGUE")
        .count()
    )

    # -------------------------
    # AGUARDANDO MATERIAL
    # -------------------------

    pedidos_aguardando_material = Pedido.objects.filter(
        status_atual="AGUARDANDO_MATERIAL"
    ).count()

    # -------------------------
    # RESERVA INCOMPLETA
    # -------------------------

    pedidos_reserva_incompleta = Pedido.objects.filter(
        status_atual="RESERVADO_INCOMPLETO"
    ).count()

    # -------------------------
    # TOTAL DE ALERTAS
    # -------------------------

    total_alertas = (
        produtos_estoque_critico
        + pedidos_atrasados
        + pedidos_aguardando_material
        + pedidos_reserva_incompleta
    )

    # =========================
    # CLIENTES ATIVOS
    # =========================

    clientes_ativos = Cliente.objects.filter(ativo=True).count()

    # =========================
    # CONTEXTO
    # =========================

    context = {
        "pedidos_mes": pedidos_mes,
        "produtos_estoque": produtos_estoque,
        "estoque_destaque": estoque_destaque,
        "entregas_hoje": entregas_hoje,
        "clientes_ativos": clientes_ativos,
        "pode_ver_faturamento": pode_ver_faturamento,
        "usuario_operacional": usuario_operacional,
        "pedidos_status_total": pedidos_status_total,
        "status_entregues": status_entregues,
        "status_em_entrega": status_em_entrega,
        "status_aguardando_entrega": status_aguardando_entrega,
        "status_aguardando_material": status_aguardando_material,
        "status_preparacao": status_preparacao,
        "atividades_recentes": atividades_recentes,
        "pct_entregues": pct_entregues,
        "pct_em_entrega": pct_em_entrega,
        "pct_aguardando_entrega": pct_aguardando_entrega,
        "pct_aguardando_material": pct_aguardando_material,
        "pct_preparacao": pct_preparacao,
        "fim_entregues": fim_entregues,
        "fim_em_entrega": fim_em_entrega,
        "fim_aguardando_entrega": fim_aguardando_entrega,
        "fim_aguardando_material": fim_aguardando_material,
        "nps_score": nps_score,
        "total_respostas_nps": total_respostas_nps,
        "pct_promotores_nps": pct_promotores_nps,
        "pct_neutros_nps": pct_neutros_nps,
        "pct_detratores_nps": pct_detratores_nps,
        "produtos_estoque_critico": produtos_estoque_critico,
        "pedidos_atrasados": pedidos_atrasados,
        "pedidos_aguardando_material": pedidos_aguardando_material,
        "pedidos_reserva_incompleta": pedidos_reserva_incompleta,
        "total_alertas": total_alertas,
    }

    return render(
        request,
        "dashboard.html",
        context,
    )
