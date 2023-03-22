
import 'dart:convert';

IdentificationNumber identificationNumberFromJson(String str) =>
    IdentificationNumber.fromJson(json.decode(str));
class IdentificationNumber {
  String? ndId;
  String? name;
  bool? status;

  IdentificationNumber({this.ndId, this.name, this.status});

  IdentificationNumber.fromJson(Map<String, dynamic> json) {
    ndId = json['NdId'];
    name = json['Name'];
    status = json['Status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NdId'] = this.ndId;
    data['Name'] = this.name;
    data['Status'] = this.status;
    return data;
  }
}
