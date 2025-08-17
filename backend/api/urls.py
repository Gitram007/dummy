from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import MaterialViewSet, ProductViewSet, ProductionLogViewSet, ProductMaterialViewSet

router = DefaultRouter()
router.register(r'materials', MaterialViewSet)
router.register(r'products', ProductViewSet)
router.register(r'productionlogs', ProductionLogViewSet)
router.register(r'productmaterials', ProductMaterialViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
