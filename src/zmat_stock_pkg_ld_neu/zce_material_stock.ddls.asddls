@EndUserText.label: 'Material Stock API'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MATERIAL_STOCK_QUERY'
@Metadata.allowExtensions: true
define custom entity ZCE_MATERIAL_STOCK
{
  @UI.lineItem: [{ position: 10, label: 'Material' }]
  key Material                     : abap.char(40);

  @UI.lineItem: [{ position: 20, label: 'Plant' }]
  key    Plant                        : abap.char(4);

  @UI.lineItem: [{ position: 30, label: 'Storage Location' }]
  key    StorageLocation              : abap.char(4);

  @UI.lineItem: [{ position: 40, label: 'Batch' }]
  key    Batch                        : abap.char(10);

  @UI.lineItem: [{ position: 50, label: 'MRP Area' }]
      MRPArea                      : abap.char(10);

  @UI.lineItem: [{ position: 60, label: 'Material Base Unit' }]
      MaterialBaseUnit             : abap.char(3);

  @UI.lineItem: [{ position: 70, label: 'Stock Quantity' }]
      MatlWrhsStkQtyInMatlBaseUnit : abap.char(30);
}
