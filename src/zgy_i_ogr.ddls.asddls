@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface view entity - Öğrenci'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity zgy_i_ogr
  as select from zgy_t_0001
  association to ZGY_i_cinsiyet as _cinsiyet on $projection.Cinsiyet = _cinsiyet.Value
  composition[0..*] of zgy_i_sonuc as _sonuc
{
  key id                 as Id,
      ad                 as Ad,
      soyad              as Soyad,
      zgy_t_0001.yas     as Yas,
      ders               as Ders,
      derssure           as Derssure,
      durum              as Durum,
      cinsiyet           as Cinsiyet,
      dt                 as Dt,
      lastchangedat      as Lastchangedat,
      locallastchangedat as Locallastchangedat,
      _cinsiyet,
      _cinsiyet.Description as Cinsiyetdesc,
      _sonuc
}
