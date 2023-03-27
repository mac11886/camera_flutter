
import 'dart:convert';

IdentificationNumber identificationNumberFromJson(String str) =>
    IdentificationNumber.fromJson(json.decode(str));
class IdentificationNumber {
  bool? result;
  int? status;
  String? message;
  Data? data;

  IdentificationNumber({this.result, this.status, this.message, this.data});

  IdentificationNumber.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? idCard;
  String? name;
  String? address;
  String? dob;
  String? pic;

  Data({this.idCard, this.name, this.address, this.dob, this.pic});

  Data.fromJson(Map<String, dynamic> json) {
    idCard = json['id_card'];
    name = json['name'];
    address = json['address'];
    dob = json['dob'];
    pic = json['pic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_card'] = this.idCard;
    data['name'] = this.name;
    data['address'] = this.address;
    data['dob'] = this.dob;
    data['pic'] = this.pic;
    return data;
  }
}
