abstract class Serializable {
  fromJson(Map<String, dynamic>? json);

  Map<String, dynamic> toJson();

  listFromJson(List? json);
}
