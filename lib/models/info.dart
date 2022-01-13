class Info {
  Info.fromJson(Map<String,dynamic> json):

        description = json['description'],
        icon = json['icon'];

  final String description;
  final String icon;
}