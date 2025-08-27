// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  name: json['name'] as String?,
  email: json['email'] as String,
  photo: json['photo'] as String?,
  givenName: json['givenName'] as String?,
  familyName: json['familyName'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'photo': instance.photo,
  'givenName': instance.givenName,
  'familyName': instance.familyName,
};

AuthState _$AuthStateFromJson(Map<String, dynamic> json) => AuthState(
  isAuthenticated: json['isAuthenticated'] as bool? ?? false,
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  isLoading: json['isLoading'] as bool? ?? true,
  idToken: json['idToken'] as String?,
  accessToken: json['accessToken'] as String?,
  serverAuthCode: json['serverAuthCode'] as String?,
  tokenExpiry: (json['tokenExpiry'] as num?)?.toInt(),
  jwtToken: json['jwtToken'] as String?,
);

Map<String, dynamic> _$AuthStateToJson(AuthState instance) => <String, dynamic>{
  'isAuthenticated': instance.isAuthenticated,
  'user': instance.user,
  'isLoading': instance.isLoading,
  'idToken': instance.idToken,
  'accessToken': instance.accessToken,
  'serverAuthCode': instance.serverAuthCode,
  'tokenExpiry': instance.tokenExpiry,
  'jwtToken': instance.jwtToken,
};

AuthData _$AuthDataFromJson(Map<String, dynamic> json) => AuthData(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  idToken: json['idToken'] as String?,
  accessToken: json['accessToken'] as String?,
  serverAuthCode: json['serverAuthCode'] as String?,
  scopes: (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList(),
  timestamp: json['timestamp'] as String,
  tokenExpiry: (json['tokenExpiry'] as num?)?.toInt(),
  jwtToken: json['jwtToken'] as String?,
  jwtTokenExpiry: (json['jwtTokenExpiry'] as num?)?.toInt(),
);

Map<String, dynamic> _$AuthDataToJson(AuthData instance) => <String, dynamic>{
  'user': instance.user,
  'idToken': instance.idToken,
  'accessToken': instance.accessToken,
  'serverAuthCode': instance.serverAuthCode,
  'scopes': instance.scopes,
  'timestamp': instance.timestamp,
  'tokenExpiry': instance.tokenExpiry,
  'jwtToken': instance.jwtToken,
  'jwtTokenExpiry': instance.jwtTokenExpiry,
};

UserServiceResponse _$UserServiceResponseFromJson(Map<String, dynamic> json) =>
    UserServiceResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserServiceResponseToJson(
  UserServiceResponse instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'user': instance.user,
};

GoogleSignInRequest _$GoogleSignInRequestFromJson(Map<String, dynamic> json) =>
    GoogleSignInRequest(
      accessToken: json['accessToken'] as String,
      serverAuthCode: json['serverAuthCode'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$GoogleSignInRequestToJson(
  GoogleSignInRequest instance,
) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'serverAuthCode': instance.serverAuthCode,
  'email': instance.email,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
};
