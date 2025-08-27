import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String? name;
  final String email;
  final String? photo;
  final String? givenName;
  final String? familyName;

  User({
    required this.id,
    this.name,
    required this.email,
    this.photo,
    this.givenName,
    this.familyName,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? idToken;
  final String? accessToken;
  final String? serverAuthCode;
  final int? tokenExpiry;
  final String? jwtToken;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = true,
    this.idToken,
    this.accessToken,
    this.serverAuthCode,
    this.tokenExpiry,
    this.jwtToken,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? idToken,
    String? accessToken,
    String? serverAuthCode,
    int? tokenExpiry,
    String? jwtToken,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      idToken: idToken ?? this.idToken,
      accessToken: accessToken ?? this.accessToken,
      serverAuthCode: serverAuthCode ?? this.serverAuthCode,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      jwtToken: jwtToken ?? this.jwtToken,
    );
  }



  factory AuthState.fromJson(Map<String, dynamic> json) => _$AuthStateFromJson(json);
  Map<String, dynamic> toJson() => _$AuthStateToJson(this);
}

@JsonSerializable()
class AuthData {
  final User user;
  final String? idToken;
  final String? accessToken;
  final String? serverAuthCode;
  final List<String>? scopes;
  final String timestamp;
  final int? tokenExpiry;
  final String? jwtToken;
  final int? jwtTokenExpiry;

  AuthData({
    required this.user,
    this.idToken,
    this.accessToken,
    this.serverAuthCode,
    this.scopes,
    required this.timestamp,
    this.tokenExpiry,
    this.jwtToken,
    this.jwtTokenExpiry,
  });

  AuthData copyWith({
    User? user,
    String? idToken,
    String? accessToken,
    String? serverAuthCode,
    List<String>? scopes,
    String? timestamp,
    int? tokenExpiry,
    String? jwtToken,
    int? jwtTokenExpiry,
  }) {
    return AuthData(
      user: user ?? this.user,
      idToken: idToken ?? this.idToken,
      accessToken: accessToken ?? this.accessToken,
      serverAuthCode: serverAuthCode ?? this.serverAuthCode,
      scopes: scopes ?? this.scopes,
      timestamp: timestamp ?? this.timestamp,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      jwtToken: jwtToken ?? this.jwtToken,
      jwtTokenExpiry: jwtTokenExpiry ?? this.jwtTokenExpiry,
    );
  }

  factory AuthData.fromJson(Map<String, dynamic> json) => _$AuthDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthDataToJson(this);
}

@JsonSerializable()
class UserServiceResponse {
  final String accessToken;
  final String? refreshToken;
  final User user;

  UserServiceResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory UserServiceResponse.fromJson(Map<String, dynamic> json) => _$UserServiceResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserServiceResponseToJson(this);
}

@JsonSerializable()
class GoogleSignInRequest {
  final String accessToken;
  final String serverAuthCode;
  final String email;
  final String name;
  final String? avatarUrl;

  GoogleSignInRequest({
    required this.accessToken,
    required this.serverAuthCode,
    required this.email,
    required this.name,
    this.avatarUrl,
  });

  factory GoogleSignInRequest.fromJson(Map<String, dynamic> json) => _$GoogleSignInRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GoogleSignInRequestToJson(this);
}
