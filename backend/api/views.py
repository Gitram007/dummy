from rest_framework import viewsets
from .models import Material, Product, ProductionLog, ProductMaterial
from .serializers import MaterialSerializer, ProductSerializer, ProductionLogSerializer, ProductMaterialSerializer

class MaterialViewSet(viewsets.ModelViewSet):
    queryset = Material.objects.all()
    serializer_class = MaterialSerializer

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer

class ProductionLogViewSet(viewsets.ModelViewSet):
    serializer_class = ProductionLogSerializer

    def get_queryset(self):
        queryset = ProductionLog.objects.all()
        start_date = self.request.query_params.get('start_date')
        end_date = self.request.query_params.get('end_date')
        product_id = self.request.query_params.get('product_id')

        if start_date and end_date:
            queryset = queryset.filter(production_date__range=[start_date, end_date])

        if product_id:
            queryset = queryset.filter(product_id=product_id)

        return queryset

class ProductMaterialViewSet(viewsets.ModelViewSet):
    serializer_class = ProductMaterialSerializer

    def get_queryset(self):
        queryset = ProductMaterial.objects.all()
        product_id = self.request.query_params.get('product_id')
        material_id = self.request.query_params.get('material_id')

        if product_id:
            queryset = queryset.filter(product_id=product_id)

        if material_id:
            queryset = queryset.filter(material_id=material_id)

        return queryset
