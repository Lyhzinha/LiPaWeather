class Info {
  Info.fromJson(Map<String,dynamic> json):

        main = json['main'],
        icon = json['icon'];

  Map<String, dynamic> toJson() => {
    'main': main,
    'icon': icon
  };

  final String main;
  final String icon;
}