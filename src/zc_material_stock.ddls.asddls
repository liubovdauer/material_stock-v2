@EndUserText.label: 'Material Stock Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true      

define root view entity ZC_MATERIAL_STOCK
  provider contract transactional_query
  as projection on ZI_MATERIAL_STOCK
{
  key Material,
  key Plant,
  key StorageLocation,
  key Batch,
      MrpArea,
      MaterialBaseUnit,
      StockQuantity
}
