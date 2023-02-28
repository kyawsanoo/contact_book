class Contact {
  late String id;
  late String name;
  late String company;
  late String phone;

  Contact(this.id, {required this.name, required this.company, required this.phone});

  Contact.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    company = json['company'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['company'] = company;
    data['phone'] = phone;
    return data;
  }

}
