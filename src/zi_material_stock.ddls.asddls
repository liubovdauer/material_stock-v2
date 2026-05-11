@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MATERIAL_STOCK'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define root view entity ZI_MATERIAL_STOCK as select from zmat_stock
{
  key material           as Material,
  key plant              as Plant,
  key storage_location   as StorageLocation,
  key batch              as Batch,
      mrp_area           as MrpArea,
      material_base_unit as MaterialBaseUnit,
      stock_qty          as StockQuantity,
      last_changed_datetime as LastChangedDateTime
}
