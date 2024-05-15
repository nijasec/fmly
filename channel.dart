class Channel {

 final String STATION_NAME;
 final int ID;
 final String SURL;

 const Channel({
  required this.ID,
  required this.STATION_NAME,
  required this.SURL
 });
  
  static Channel fromJson(json)=> Channel(ID: json['ID'], STATION_NAME: json['STATION_NAME'],SURL: json['URL']);


}