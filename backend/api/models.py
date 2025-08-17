from django.db import models

class Material(models.Model):
    name = models.CharField(max_length=255)
    quantity = models.FloatField()
    unit = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class Product(models.Model):
    name = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    materials = models.ManyToManyField(Material, through='ProductMaterial')

    def __str__(self):
        return self.name

class ProductionLog(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity_produced = models.FloatField()
    production_date = models.DateTimeField()

    def __str__(self):
        return f"{self.product.name} - {self.production_date}"

class ProductMaterial(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    material = models.ForeignKey(Material, on_delete=models.CASCADE)
    quantity = models.FloatField()
    assigned_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('product', 'material')

    def __str__(self):
        return f"{self.product.name} - {self.material.name}"
