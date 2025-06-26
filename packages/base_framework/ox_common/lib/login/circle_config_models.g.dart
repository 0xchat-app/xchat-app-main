// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_config_models.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetCircleConfigISARCollection on Isar {
  IsarCollection<int, CircleConfigISAR> get circleConfigISARs =>
      this.collection();
}

const CircleConfigISARSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'CircleConfigISAR',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'circleId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'keyName',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'stringValue',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'intValue',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'doubleValue',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'boolValue',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'updatedAt',
        type: IsarType.long,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'keyName',
        properties: [
          "keyName",
        ],
        unique: true,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, CircleConfigISAR>(
    serialize: serializeCircleConfigISAR,
    deserialize: deserializeCircleConfigISAR,
    deserializeProperty: deserializeCircleConfigISARProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeCircleConfigISAR(IsarWriter writer, CircleConfigISAR object) {
  IsarCore.writeString(writer, 1, object.circleId);
  IsarCore.writeString(writer, 2, object.keyName);
  {
    final value = object.stringValue;
    if (value == null) {
      IsarCore.writeNull(writer, 3);
    } else {
      IsarCore.writeString(writer, 3, value);
    }
  }
  IsarCore.writeLong(writer, 4, object.intValue ?? -9223372036854775808);
  IsarCore.writeDouble(writer, 5, object.doubleValue ?? double.nan);
  {
    final value = object.boolValue;
    if (value == null) {
      IsarCore.writeNull(writer, 6);
    } else {
      IsarCore.writeBool(writer, 6, value);
    }
  }
  IsarCore.writeLong(writer, 7, object.updatedAt);
  return object.id;
}

@isarProtected
CircleConfigISAR deserializeCircleConfigISAR(IsarReader reader) {
  final String _circleId;
  _circleId = IsarCore.readString(reader, 1) ?? '';
  final String _keyName;
  _keyName = IsarCore.readString(reader, 2) ?? '';
  final String? _stringValue;
  _stringValue = IsarCore.readString(reader, 3);
  final int? _intValue;
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      _intValue = null;
    } else {
      _intValue = value;
    }
  }
  final double? _doubleValue;
  {
    final value = IsarCore.readDouble(reader, 5);
    if (value.isNaN) {
      _doubleValue = null;
    } else {
      _doubleValue = value;
    }
  }
  final bool? _boolValue;
  {
    if (IsarCore.readNull(reader, 6)) {
      _boolValue = null;
    } else {
      _boolValue = IsarCore.readBool(reader, 6);
    }
  }
  final int _updatedAt;
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      _updatedAt = 0;
    } else {
      _updatedAt = value;
    }
  }
  final object = CircleConfigISAR(
    circleId: _circleId,
    keyName: _keyName,
    stringValue: _stringValue,
    intValue: _intValue,
    doubleValue: _doubleValue,
    boolValue: _boolValue,
    updatedAt: _updatedAt,
  );
  object.id = IsarCore.readId(reader);
  return object;
}

@isarProtected
dynamic deserializeCircleConfigISARProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3);
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 5:
      {
        final value = IsarCore.readDouble(reader, 5);
        if (value.isNaN) {
          return null;
        } else {
          return value;
        }
      }
    case 6:
      {
        if (IsarCore.readNull(reader, 6)) {
          return null;
        } else {
          return IsarCore.readBool(reader, 6);
        }
      }
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return 0;
        } else {
          return value;
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _CircleConfigISARUpdate {
  bool call({
    required int id,
    String? circleId,
    String? keyName,
    String? stringValue,
    int? intValue,
    double? doubleValue,
    bool? boolValue,
    int? updatedAt,
  });
}

class _CircleConfigISARUpdateImpl implements _CircleConfigISARUpdate {
  const _CircleConfigISARUpdateImpl(this.collection);

  final IsarCollection<int, CircleConfigISAR> collection;

  @override
  bool call({
    required int id,
    Object? circleId = ignore,
    Object? keyName = ignore,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? doubleValue = ignore,
    Object? boolValue = ignore,
    Object? updatedAt = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (circleId != ignore) 1: circleId as String?,
          if (keyName != ignore) 2: keyName as String?,
          if (stringValue != ignore) 3: stringValue as String?,
          if (intValue != ignore) 4: intValue as int?,
          if (doubleValue != ignore) 5: doubleValue as double?,
          if (boolValue != ignore) 6: boolValue as bool?,
          if (updatedAt != ignore) 7: updatedAt as int?,
        }) >
        0;
  }
}

sealed class _CircleConfigISARUpdateAll {
  int call({
    required List<int> id,
    String? circleId,
    String? keyName,
    String? stringValue,
    int? intValue,
    double? doubleValue,
    bool? boolValue,
    int? updatedAt,
  });
}

class _CircleConfigISARUpdateAllImpl implements _CircleConfigISARUpdateAll {
  const _CircleConfigISARUpdateAllImpl(this.collection);

  final IsarCollection<int, CircleConfigISAR> collection;

  @override
  int call({
    required List<int> id,
    Object? circleId = ignore,
    Object? keyName = ignore,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? doubleValue = ignore,
    Object? boolValue = ignore,
    Object? updatedAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (circleId != ignore) 1: circleId as String?,
      if (keyName != ignore) 2: keyName as String?,
      if (stringValue != ignore) 3: stringValue as String?,
      if (intValue != ignore) 4: intValue as int?,
      if (doubleValue != ignore) 5: doubleValue as double?,
      if (boolValue != ignore) 6: boolValue as bool?,
      if (updatedAt != ignore) 7: updatedAt as int?,
    });
  }
}

extension CircleConfigISARUpdate on IsarCollection<int, CircleConfigISAR> {
  _CircleConfigISARUpdate get update => _CircleConfigISARUpdateImpl(this);

  _CircleConfigISARUpdateAll get updateAll =>
      _CircleConfigISARUpdateAllImpl(this);
}

sealed class _CircleConfigISARQueryUpdate {
  int call({
    String? circleId,
    String? keyName,
    String? stringValue,
    int? intValue,
    double? doubleValue,
    bool? boolValue,
    int? updatedAt,
  });
}

class _CircleConfigISARQueryUpdateImpl implements _CircleConfigISARQueryUpdate {
  const _CircleConfigISARQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<CircleConfigISAR> query;
  final int? limit;

  @override
  int call({
    Object? circleId = ignore,
    Object? keyName = ignore,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? doubleValue = ignore,
    Object? boolValue = ignore,
    Object? updatedAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (circleId != ignore) 1: circleId as String?,
      if (keyName != ignore) 2: keyName as String?,
      if (stringValue != ignore) 3: stringValue as String?,
      if (intValue != ignore) 4: intValue as int?,
      if (doubleValue != ignore) 5: doubleValue as double?,
      if (boolValue != ignore) 6: boolValue as bool?,
      if (updatedAt != ignore) 7: updatedAt as int?,
    });
  }
}

extension CircleConfigISARQueryUpdate on IsarQuery<CircleConfigISAR> {
  _CircleConfigISARQueryUpdate get updateFirst =>
      _CircleConfigISARQueryUpdateImpl(this, limit: 1);

  _CircleConfigISARQueryUpdate get updateAll =>
      _CircleConfigISARQueryUpdateImpl(this);
}

class _CircleConfigISARQueryBuilderUpdateImpl
    implements _CircleConfigISARQueryUpdate {
  const _CircleConfigISARQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<CircleConfigISAR, CircleConfigISAR, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? circleId = ignore,
    Object? keyName = ignore,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? doubleValue = ignore,
    Object? boolValue = ignore,
    Object? updatedAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (circleId != ignore) 1: circleId as String?,
        if (keyName != ignore) 2: keyName as String?,
        if (stringValue != ignore) 3: stringValue as String?,
        if (intValue != ignore) 4: intValue as int?,
        if (doubleValue != ignore) 5: doubleValue as double?,
        if (boolValue != ignore) 6: boolValue as bool?,
        if (updatedAt != ignore) 7: updatedAt as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension CircleConfigISARQueryBuilderUpdate
    on QueryBuilder<CircleConfigISAR, CircleConfigISAR, QOperations> {
  _CircleConfigISARQueryUpdate get updateFirst =>
      _CircleConfigISARQueryBuilderUpdateImpl(this, limit: 1);

  _CircleConfigISARQueryUpdate get updateAll =>
      _CircleConfigISARQueryBuilderUpdateImpl(this);
}

extension CircleConfigISARQueryFilter
    on QueryBuilder<CircleConfigISAR, CircleConfigISAR, QFilterCondition> {
  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 0,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 0,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      circleIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      keyNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      stringValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      intValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      intValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      intValueEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      intValueGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      intValueGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      intValueLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      intValueLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      intValueBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      doubleValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      doubleValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      doubleValueEqualTo(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      doubleValueGreaterThan(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      doubleValueGreaterThanOrEqualTo(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      doubleValueLessThan(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      doubleValueLessThanOrEqualTo(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      doubleValueBetween(
    double? lower,
    double? upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      boolValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      boolValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      boolValueEqualTo(
    bool? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      updatedAtEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      updatedAtGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      updatedAtGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      updatedAtLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      updatedAtLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterFilterCondition>
      updatedAtBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension CircleConfigISARQueryObject
    on QueryBuilder<CircleConfigISAR, CircleConfigISAR, QFilterCondition> {}

extension CircleConfigISARQuerySortBy
    on QueryBuilder<CircleConfigISAR, CircleConfigISAR, QSortBy> {
  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy> sortByCircleId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByCircleIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy> sortByKeyName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByKeyNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByStringValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByStringValueDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByDoubleValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByBoolValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }
}

extension CircleConfigISARQuerySortThenBy
    on QueryBuilder<CircleConfigISAR, CircleConfigISAR, QSortThenBy> {
  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy> thenByCircleId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByCircleIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy> thenByKeyName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByKeyNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByStringValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByStringValueDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByDoubleValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByBoolValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }
}

extension CircleConfigISARQueryWhereDistinct
    on QueryBuilder<CircleConfigISAR, CircleConfigISAR, QDistinct> {
  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterDistinct>
      distinctByCircleId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterDistinct>
      distinctByKeyName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterDistinct>
      distinctByStringValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterDistinct>
      distinctByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterDistinct>
      distinctByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterDistinct>
      distinctByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<CircleConfigISAR, CircleConfigISAR, QAfterDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }
}

extension CircleConfigISARQueryProperty1
    on QueryBuilder<CircleConfigISAR, CircleConfigISAR, QProperty> {
  QueryBuilder<CircleConfigISAR, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<CircleConfigISAR, String, QAfterProperty> circleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<CircleConfigISAR, String, QAfterProperty> keyNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<CircleConfigISAR, String?, QAfterProperty>
      stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<CircleConfigISAR, int?, QAfterProperty> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<CircleConfigISAR, double?, QAfterProperty>
      doubleValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<CircleConfigISAR, bool?, QAfterProperty> boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<CircleConfigISAR, int, QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }
}

extension CircleConfigISARQueryProperty2<R>
    on QueryBuilder<CircleConfigISAR, R, QAfterProperty> {
  QueryBuilder<CircleConfigISAR, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<CircleConfigISAR, (R, String), QAfterProperty>
      circleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<CircleConfigISAR, (R, String), QAfterProperty>
      keyNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<CircleConfigISAR, (R, String?), QAfterProperty>
      stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<CircleConfigISAR, (R, int?), QAfterProperty> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<CircleConfigISAR, (R, double?), QAfterProperty>
      doubleValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<CircleConfigISAR, (R, bool?), QAfterProperty>
      boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<CircleConfigISAR, (R, int), QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }
}

extension CircleConfigISARQueryProperty3<R1, R2>
    on QueryBuilder<CircleConfigISAR, (R1, R2), QAfterProperty> {
  QueryBuilder<CircleConfigISAR, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<CircleConfigISAR, (R1, R2, String), QOperations>
      circleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<CircleConfigISAR, (R1, R2, String), QOperations>
      keyNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<CircleConfigISAR, (R1, R2, String?), QOperations>
      stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<CircleConfigISAR, (R1, R2, int?), QOperations>
      intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<CircleConfigISAR, (R1, R2, double?), QOperations>
      doubleValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<CircleConfigISAR, (R1, R2, bool?), QOperations>
      boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<CircleConfigISAR, (R1, R2, int), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }
}
