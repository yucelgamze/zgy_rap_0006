@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface view entity - Sonuç'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define view entity zgy_i_sonuc
  as select from zgy_t_0002
  //  header tabloyu association to parent olarak ekliyoruz
  association to parent zgy_i_ogr as _ogr     on $projection.Id = _ogr.Id
  association to zgy_i_ders       as _ders    on $projection.Ders = _ders.Value
  association to zgy_i_yariyil    as _yariyil on $projection.Yariyil = _yariyil.Value
  association to zgy_i_not        as _not     on $projection.Notsonuc = _not.Value
{
  key id                   as Id,
  key ders                 as Ders,
  key yariyil              as Yariyil,
      notsonuc             as Notsonuc,
      _ogr,
      _ogr.Lastchangedat   as Lastchangedat,
      _ders.Description    as Ders_desc,
      _yariyil.Description as Yariyil_desc,
      _not.Description     as Notsonuc_desc

}
