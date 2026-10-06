"""
URL configuration for config project.
"""

from django.contrib import admin
from django.urls import include, path

from core.views import dashboard

urlpatterns = [
    path(
        "admin/",
        admin.site.urls,
    ),
    path(
        "",
        dashboard,
        name="dashboard",
    ),
    path(
        "pedidos/",
        include("pedidos.urls"),
    ),
]
