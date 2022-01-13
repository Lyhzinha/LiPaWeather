class Info {
  Info.fromJson(Map<String,dynamic> json):

        main = json['main'],
        icon = json['icon'];

  final String main;
  final String icon;
}