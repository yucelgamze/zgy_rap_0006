@EndUserText.label: 'Consumption View Entity-Sonuç projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZGY_C_SONUC
  as projection on zgy_i_sonuc
{
      @EndUserText.label: 'Öğrenci ID'
  key Id,
      @EndUserText.label: 'Ders'
  key Ders,
      @EndUserText.label: 'Yarıyıl'
  key Yariyil,
      @EndUserText.label: 'Not Sonucu'
      Notsonuc,
      Lastchangedat,
      @EndUserText.label: 'Ders Açıklaması'
      Ders_desc,
      @EndUserText.label: 'Yarıyıl Açıklaması'
      Yariyil_desc,
      @EndUserText.label: 'Not Sonucu Açıklaması'
      Notsonuc_desc,
      /* Associations */
      _ogr : redirected to parent ZGY_C_OGR
}
