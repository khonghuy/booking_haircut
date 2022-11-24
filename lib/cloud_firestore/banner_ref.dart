import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booking_haircut/model/image_model.dart';



Future<List<ImageModel>> getBanners() async{
  List<ImageModel> result = new List<ImageModel>.empty(growable: true);
  CollectionReference bannerRef = FirebaseFirestore.instance.collection('Banner');
  QuerySnapshot snapshot = await bannerRef.get();
  snapshot.docs.forEach((element){
    result.add(ImageModel.fromJson(element.data()));

  });
  return result;

}
