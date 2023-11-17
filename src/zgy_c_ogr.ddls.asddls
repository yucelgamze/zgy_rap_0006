@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption View Entity - Öğrenci'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZGY_C_OGR
  provider contract transactional_query
  as projection on zgy_i_ogr
{
      @EndUserText.label: 'Ogrenci ID'
  key Id,
      @EndUserText.label: 'Ad'
      Ad,
      @EndUserText.label: 'Soyad'
      Soyad,
      @EndUserText.label: 'Yas'
      Yas,
      @EndUserText.label: 'Ders'
      Ders,
      @EndUserText.label: 'Ders Saati'
      Derssure,
      @EndUserText.label: 'Durum'
      Durum,
      @EndUserText.label: 'Cinsiyet'
      Cinsiyet,
      Cinsiyetdesc,
      @EndUserText.label: 'Dogum Tarihi'
      Dt,
      Lastchangedat,
      Locallastchangedat,
      /* Associations */
      _cinsiyet,
      _sonuc : redirected to composition child ZGY_C_SONUC
}
