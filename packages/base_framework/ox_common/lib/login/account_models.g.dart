// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_models.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetAccountDataISARCollection on Isar {
  IsarCollection<int, AccountDataISAR> get accountDataISARs =>
      this.collection();
}

const AccountDataISARSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'AccountDataISAR',
    idName: 'id',
    embedded: false,
    properties: [
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
  converter: IsarObjectConverter<int, AccountDataISAR>(
    serialize: serializeAccountDataISAR,
    deserialize: deserializeAccountDataISAR,
    deserializeProperty: deserializeAccountDataISARProp,
  ),
  embeddedSchemas: [],
);

@isarProtected
int serializeAccountDataISAR(IsarWriter writer, AccountDataISAR object) {
  IsarCore.writeString(writer, 1, object.keyName);
  {
    final value = object.stringValue;
    if (value == null) {
      IsarCore.writeNull(writer, 2);
    } else {
      IsarCore.writeString(writer, 2, value);
    }
  }
  IsarCore.writeLong(writer, 3, object.intValue ?? -9223372036854775808);
  IsarCore.writeDouble(writer, 4, object.doubleValue ?? double.nan);
  {
    final value = object.boolValue;
    if (value == null) {
      IsarCore.writeNull(writer, 5);
    } else {
      IsarCore.writeBool(writer, 5, value);
    }
  }
  IsarCore.writeLong(writer, 6, object.updatedAt);
  return object.id;
}

@isarProtected
AccountDataISAR deserializeAccountDataISAR(IsarReader reader) {
  final String _keyName;
  _keyName = IsarCore.readString(reader, 1) ?? '';
  final String? _stringValue;
  _stringValue = IsarCore.readString(reader, 2);
  final int? _intValue;
  {
    final value = IsarCore.readLong(reader, 3);
    if (value == -9223372036854775808) {
      _intValue = null;
    } else {
      _intValue = value;
    }
  }
  final double? _doubleValue;
  {
    final value = IsarCore.readDouble(reader, 4);
    if (value.isNaN) {
      _doubleValue = null;
    } else {
      _doubleValue = value;
    }
  }
  final bool? _boolValue;
  {
    if (IsarCore.readNull(reader, 5)) {
      _boolValue = null;
    } else {
      _boolValue = IsarCore.readBool(reader, 5);
    }
  }
  final int _updatedAt;
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      _updatedAt = 0;
    } else {
      _updatedAt = value;
    }
  }
  final object = AccountDataISAR(
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
dynamic deserializeAccountDataISARProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2);
    case 3:
      {
        final value = IsarCore.readLong(reader, 3);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 4:
      {
        final value = IsarCore.readDouble(reader, 4);
        if (value.isNaN) {
          return null;
        } else {
          return value;
        }
      }
    case 5:
      {
        if (IsarCore.readNull(reader, 5)) {
          return null;
        } else {
          return IsarCore.readBool(reader, 5);
        }
      }
    case 6:
      {
        final value = IsarCore.readLong(reader, 6);
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

sealed class _AccountDataISARUpdate {
  bool call({
    required int id,
    String? keyName,
    String? stringValue,
    int? intValue,
    double? doubleValue,
    bool? boolValue,
    int? updatedAt,
  });
}

class _AccountDataISARUpdateImpl implements _AccountDataISARUpdate {
  const _AccountDataISARUpdateImpl(this.collection);

  final IsarCollection<int, AccountDataISAR> collection;

  @override
  bool call({
    required int id,
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
          if (keyName != ignore) 1: keyName as String?,
          if (stringValue != ignore) 2: stringValue as String?,
          if (intValue != ignore) 3: intValue as int?,
          if (doubleValue != ignore) 4: doubleValue as double?,
          if (boolValue != ignore) 5: boolValue as bool?,
          if (updatedAt != ignore) 6: updatedAt as int?,
        }) >
        0;
  }
}

sealed class _AccountDataISARUpdateAll {
  int call({
    required List<int> id,
    String? keyName,
    String? stringValue,
    int? intValue,
    double? doubleValue,
    bool? boolValue,
    int? updatedAt,
  });
}

class _AccountDataISARUpdateAllImpl implements _AccountDataISARUpdateAll {
  const _AccountDataISARUpdateAllImpl(this.collection);

  final IsarCollection<int, AccountDataISAR> collection;

  @override
  int call({
    required List<int> id,
    Object? keyName = ignore,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? doubleValue = ignore,
    Object? boolValue = ignore,
    Object? updatedAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (keyName != ignore) 1: keyName as String?,
      if (stringValue != ignore) 2: stringValue as String?,
      if (intValue != ignore) 3: intValue as int?,
      if (doubleValue != ignore) 4: doubleValue as double?,
      if (boolValue != ignore) 5: boolValue as bool?,
      if (updatedAt != ignore) 6: updatedAt as int?,
    });
  }
}

extension AccountDataISARUpdate on IsarCollection<int, AccountDataISAR> {
  _AccountDataISARUpdate get update => _AccountDataISARUpdateImpl(this);

  _AccountDataISARUpdateAll get updateAll =>
      _AccountDataISARUpdateAllImpl(this);
}

sealed class _AccountDataISARQueryUpdate {
  int call({
    String? keyName,
    String? stringValue,
    int? intValue,
    double? doubleValue,
    bool? boolValue,
    int? updatedAt,
  });
}

class _AccountDataISARQueryUpdateImpl implements _AccountDataISARQueryUpdate {
  const _AccountDataISARQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<AccountDataISAR> query;
  final int? limit;

  @override
  int call({
    Object? keyName = ignore,
    Object? stringValue = ignore,
    Object? intValue = ignore,
    Object? doubleValue = ignore,
    Object? boolValue = ignore,
    Object? updatedAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (keyName != ignore) 1: keyName as String?,
      if (stringValue != ignore) 2: stringValue as String?,
      if (intValue != ignore) 3: intValue as int?,
      if (doubleValue != ignore) 4: doubleValue as double?,
      if (boolValue != ignore) 5: boolValue as bool?,
      if (updatedAt != ignore) 6: updatedAt as int?,
    });
  }
}

extension AccountDataISARQueryUpdate on IsarQuery<AccountDataISAR> {
  _AccountDataISARQueryUpdate get updateFirst =>
      _AccountDataISARQueryUpdateImpl(this, limit: 1);

  _AccountDataISARQueryUpdate get updateAll =>
      _AccountDataISARQueryUpdateImpl(this);
}

class _AccountDataISARQueryBuilderUpdateImpl
    implements _AccountDataISARQueryUpdate {
  const _AccountDataISARQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<AccountDataISAR, AccountDataISAR, QOperations> query;
  final int? limit;

  @override
  int call({
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
        if (keyName != ignore) 1: keyName as String?,
        if (stringValue != ignore) 2: stringValue as String?,
        if (intValue != ignore) 3: intValue as int?,
        if (doubleValue != ignore) 4: doubleValue as double?,
        if (boolValue != ignore) 5: boolValue as bool?,
        if (updatedAt != ignore) 6: updatedAt as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension AccountDataISARQueryBuilderUpdate
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QOperations> {
  _AccountDataISARQueryUpdate get updateFirst =>
      _AccountDataISARQueryBuilderUpdateImpl(this, limit: 1);

  _AccountDataISARQueryUpdate get updateAll =>
      _AccountDataISARQueryBuilderUpdateImpl(this);
}

extension AccountDataISARQueryFilter
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QFilterCondition> {
  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameEqualTo(
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameGreaterThan(
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameGreaterThanOrEqualTo(
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameLessThan(
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameLessThanOrEqualTo(
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameBetween(
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameStartsWith(
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameEndsWith(
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 2));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueEqualTo(
    String? value, {
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueGreaterThan(
    String? value, {
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueLessThan(
    String? value, {
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueStartsWith(
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueEndsWith(
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueEqualTo(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueGreaterThan(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueGreaterThanOrEqualTo(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueLessThan(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueLessThanOrEqualTo(
    double? value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueBetween(
    double? lower,
    double? upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      boolValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      boolValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      boolValueEqualTo(
    bool? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      updatedAtEqualTo(
    int value,
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

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      updatedAtGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      updatedAtGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      updatedAtLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      updatedAtLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      updatedAtBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension AccountDataISARQueryObject
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QFilterCondition> {}

extension AccountDataISARQuerySortBy
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QSortBy> {
  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> sortByKeyName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByKeyNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByStringValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByStringValueDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByDoubleValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByBoolValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension AccountDataISARQuerySortThenBy
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QSortThenBy> {
  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> thenByKeyName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByKeyNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByStringValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByStringValueDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByDoubleValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByBoolValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension AccountDataISARQueryWhereDistinct
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QDistinct> {
  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterDistinct>
      distinctByKeyName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterDistinct>
      distinctByStringValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterDistinct>
      distinctByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterDistinct>
      distinctByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterDistinct>
      distinctByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }
}

extension AccountDataISARQueryProperty1
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QProperty> {
  QueryBuilder<AccountDataISAR, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<AccountDataISAR, String, QAfterProperty> keyNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<AccountDataISAR, String?, QAfterProperty> stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<AccountDataISAR, int?, QAfterProperty> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<AccountDataISAR, double?, QAfterProperty> doubleValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<AccountDataISAR, bool?, QAfterProperty> boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<AccountDataISAR, int, QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension AccountDataISARQueryProperty2<R>
    on QueryBuilder<AccountDataISAR, R, QAfterProperty> {
  QueryBuilder<AccountDataISAR, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<AccountDataISAR, (R, String), QAfterProperty> keyNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<AccountDataISAR, (R, String?), QAfterProperty>
      stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<AccountDataISAR, (R, int?), QAfterProperty> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<AccountDataISAR, (R, double?), QAfterProperty>
      doubleValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<AccountDataISAR, (R, bool?), QAfterProperty>
      boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<AccountDataISAR, (R, int), QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension AccountDataISARQueryProperty3<R1, R2>
    on QueryBuilder<AccountDataISAR, (R1, R2), QAfterProperty> {
  QueryBuilder<AccountDataISAR, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<AccountDataISAR, (R1, R2, String), QOperations>
      keyNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<AccountDataISAR, (R1, R2, String?), QOperations>
      stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<AccountDataISAR, (R1, R2, int?), QOperations>
      intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<AccountDataISAR, (R1, R2, double?), QOperations>
      doubleValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<AccountDataISAR, (R1, R2, bool?), QOperations>
      boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<AccountDataISAR, (R1, R2, int), QOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}
