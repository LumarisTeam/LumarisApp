// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CampusPOI {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  LatLng get position => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CampusPOICopyWith<CampusPOI> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CampusPOICopyWith<$Res> {
  factory $CampusPOICopyWith(CampusPOI value, $Res Function(CampusPOI) then) =
      _$CampusPOICopyWithImpl<$Res, CampusPOI>;
  @useResult
  $Res call({String name, String description, LatLng position});
}

/// @nodoc
class _$CampusPOICopyWithImpl<$Res, $Val extends CampusPOI>
    implements $CampusPOICopyWith<$Res> {
  _$CampusPOICopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? position = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as LatLng,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CampusPOIImplCopyWith<$Res>
    implements $CampusPOICopyWith<$Res> {
  factory _$$CampusPOIImplCopyWith(
    _$CampusPOIImpl value,
    $Res Function(_$CampusPOIImpl) then,
  ) = __$$CampusPOIImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String description, LatLng position});
}

/// @nodoc
class __$$CampusPOIImplCopyWithImpl<$Res>
    extends _$CampusPOICopyWithImpl<$Res, _$CampusPOIImpl>
    implements _$$CampusPOIImplCopyWith<$Res> {
  __$$CampusPOIImplCopyWithImpl(
    _$CampusPOIImpl _value,
    $Res Function(_$CampusPOIImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? position = null,
  }) {
    return _then(
      _$CampusPOIImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as LatLng,
      ),
    );
  }
}

/// @nodoc

class _$CampusPOIImpl implements _CampusPOI {
  const _$CampusPOIImpl({
    required this.name,
    required this.description,
    required this.position,
  });

  @override
  final String name;
  @override
  final String description;
  @override
  final LatLng position;

  @override
  String toString() {
    return 'CampusPOI(name: $name, description: $description, position: $position)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CampusPOIImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.position, position) ||
                other.position == position));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, description, position);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CampusPOIImplCopyWith<_$CampusPOIImpl> get copyWith =>
      __$$CampusPOIImplCopyWithImpl<_$CampusPOIImpl>(this, _$identity);
}

abstract class _CampusPOI implements CampusPOI {
  const factory _CampusPOI({
    required final String name,
    required final String description,
    required final LatLng position,
  }) = _$CampusPOIImpl;

  @override
  String get name;
  @override
  String get description;
  @override
  LatLng get position;
  @override
  @JsonKey(ignore: true)
  _$$CampusPOIImplCopyWith<_$CampusPOIImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MapState {
  LatLng? get currentLocation => throw _privateConstructorUsedError;
  bool get isLoadingLocation => throw _privateConstructorUsedError;
  bool get isLoadingPOIs => throw _privateConstructorUsedError;
  List<CampusPOI> get campusPOIs => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MapStateCopyWith<MapState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapStateCopyWith<$Res> {
  factory $MapStateCopyWith(MapState value, $Res Function(MapState) then) =
      _$MapStateCopyWithImpl<$Res, MapState>;
  @useResult
  $Res call({
    LatLng? currentLocation,
    bool isLoadingLocation,
    bool isLoadingPOIs,
    List<CampusPOI> campusPOIs,
    String searchQuery,
  });
}

/// @nodoc
class _$MapStateCopyWithImpl<$Res, $Val extends MapState>
    implements $MapStateCopyWith<$Res> {
  _$MapStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLocation = freezed,
    Object? isLoadingLocation = null,
    Object? isLoadingPOIs = null,
    Object? campusPOIs = null,
    Object? searchQuery = null,
  }) {
    return _then(
      _value.copyWith(
            currentLocation: freezed == currentLocation
                ? _value.currentLocation
                : currentLocation // ignore: cast_nullable_to_non_nullable
                      as LatLng?,
            isLoadingLocation: null == isLoadingLocation
                ? _value.isLoadingLocation
                : isLoadingLocation // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingPOIs: null == isLoadingPOIs
                ? _value.isLoadingPOIs
                : isLoadingPOIs // ignore: cast_nullable_to_non_nullable
                      as bool,
            campusPOIs: null == campusPOIs
                ? _value.campusPOIs
                : campusPOIs // ignore: cast_nullable_to_non_nullable
                      as List<CampusPOI>,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MapStateImplCopyWith<$Res>
    implements $MapStateCopyWith<$Res> {
  factory _$$MapStateImplCopyWith(
    _$MapStateImpl value,
    $Res Function(_$MapStateImpl) then,
  ) = __$$MapStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    LatLng? currentLocation,
    bool isLoadingLocation,
    bool isLoadingPOIs,
    List<CampusPOI> campusPOIs,
    String searchQuery,
  });
}

/// @nodoc
class __$$MapStateImplCopyWithImpl<$Res>
    extends _$MapStateCopyWithImpl<$Res, _$MapStateImpl>
    implements _$$MapStateImplCopyWith<$Res> {
  __$$MapStateImplCopyWithImpl(
    _$MapStateImpl _value,
    $Res Function(_$MapStateImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLocation = freezed,
    Object? isLoadingLocation = null,
    Object? isLoadingPOIs = null,
    Object? campusPOIs = null,
    Object? searchQuery = null,
  }) {
    return _then(
      _$MapStateImpl(
        currentLocation: freezed == currentLocation
            ? _value.currentLocation
            : currentLocation // ignore: cast_nullable_to_non_nullable
                  as LatLng?,
        isLoadingLocation: null == isLoadingLocation
            ? _value.isLoadingLocation
            : isLoadingLocation // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingPOIs: null == isLoadingPOIs
            ? _value.isLoadingPOIs
            : isLoadingPOIs // ignore: cast_nullable_to_non_nullable
                  as bool,
        campusPOIs: null == campusPOIs
            ? _value._campusPOIs
            : campusPOIs // ignore: cast_nullable_to_non_nullable
                  as List<CampusPOI>,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$MapStateImpl implements _MapState {
  const _$MapStateImpl({
    this.currentLocation,
    this.isLoadingLocation = false,
    this.isLoadingPOIs = false,
    final List<CampusPOI> campusPOIs = const <CampusPOI>[],
    this.searchQuery = '',
  }) : _campusPOIs = campusPOIs;

  @override
  final LatLng? currentLocation;
  @override
  @JsonKey()
  final bool isLoadingLocation;
  @override
  @JsonKey()
  final bool isLoadingPOIs;
  final List<CampusPOI> _campusPOIs;
  @override
  @JsonKey()
  List<CampusPOI> get campusPOIs {
    if (_campusPOIs is EqualUnmodifiableListView) return _campusPOIs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_campusPOIs);
  }

  @override
  @JsonKey()
  final String searchQuery;

  @override
  String toString() {
    return 'MapState(currentLocation: $currentLocation, isLoadingLocation: $isLoadingLocation, isLoadingPOIs: $isLoadingPOIs, campusPOIs: $campusPOIs, searchQuery: $searchQuery)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapStateImpl &&
            (identical(other.currentLocation, currentLocation) ||
                other.currentLocation == currentLocation) &&
            (identical(other.isLoadingLocation, isLoadingLocation) ||
                other.isLoadingLocation == isLoadingLocation) &&
            (identical(other.isLoadingPOIs, isLoadingPOIs) ||
                other.isLoadingPOIs == isLoadingPOIs) &&
            const DeepCollectionEquality().equals(
              other._campusPOIs,
              _campusPOIs,
            ) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentLocation,
    isLoadingLocation,
    isLoadingPOIs,
    const DeepCollectionEquality().hash(_campusPOIs),
    searchQuery,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MapStateImplCopyWith<_$MapStateImpl> get copyWith =>
      __$$MapStateImplCopyWithImpl<_$MapStateImpl>(this, _$identity);
}

abstract class _MapState implements MapState {
  const factory _MapState({
    final LatLng? currentLocation,
    final bool isLoadingLocation,
    final bool isLoadingPOIs,
    final List<CampusPOI> campusPOIs,
    final String searchQuery,
  }) = _$MapStateImpl;

  @override
  LatLng? get currentLocation;
  @override
  bool get isLoadingLocation;
  @override
  bool get isLoadingPOIs;
  @override
  List<CampusPOI> get campusPOIs;
  @override
  String get searchQuery;
  @override
  @JsonKey(ignore: true)
  _$$MapStateImplCopyWith<_$MapStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
