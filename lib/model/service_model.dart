// class ServiceModel{
//   String name , docId;
//   double price;
//
//
//   ServiceModel({required this.name, required this.docId, required this.price});
//
//   ServiceModel.fromJson(Map<String,dynamic> json){
//     price = json['price'] == null ? 0 : double.parse(json['price'].toString());
//     name = json['name'];
//   }
//   Map<String ,dynamic> toJson(){
//     final Map<String ,dynamic> data = new Map<String,dynamic>();
//     data['price'] = this.price;
//     data['name'] = this.name;
//     return data;
//   }
// }