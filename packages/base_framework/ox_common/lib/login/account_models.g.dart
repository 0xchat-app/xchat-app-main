// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAccountDataISARCollection on Isar {
  IsarCollection<AccountDataISAR> get accountDataISARs => this.collection();
}

const AccountDataISARSchema = CollectionSchema(
  name: r'AccountDataISAR',
  id: 7530337607083051246,
  properties: {
    r'boolValue': PropertySchema(
      id: 0,
      name: r'boolValue',
      type: IsarType.bool,
    ),
    r'doubleValue': PropertySchema(
      id: 1,
      name: r'doubleValue',
      type: IsarType.double,
    ),
    r'intValue': PropertySchema(
      id: 2,
      name: r'intValue',
      type: IsarType.long,
    ),
    r'key': PropertySchema(
      id: 3,
      name: r'key',
      type: IsarType.string,
    ),
    r'stringValue': PropertySchema(
      id: 4,
      name: r'stringValue',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.long,
    )
  },
  estimateSize: _accountDataISAREstimateSize,
  serialize: _accountDataISARSerialize,
  deserialize: _accountDataISARDeserialize,
  deserializeProp: _accountDataISARDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _accountDataISARGetId,
  getLinks: _accountDataISARGetLinks,
  attach: _accountDataISARAttach,
  version: '3.1.0+1',
);

int _accountDataISAREstimateSize(
  AccountDataISAR object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  {
    final value = object.stringValue;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _accountDataISARSerialize(
  AccountDataISAR object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.boolValue);
  writer.writeDouble(offsets[1], object.doubleValue);
  writer.writeLong(offsets[2], object.intValue);
  writer.writeString(offsets[3], object.key);
  writer.writeString(offsets[4], object.stringValue);
  writer.writeLong(offsets[5], object.updatedAt);
}

AccountDataISAR _accountDataISARDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AccountDataISAR(
    boolValue: reader.readBoolOrNull(offsets[0]),
    doubleValue: reader.readDoubleOrNull(offsets[1]),
    intValue: reader.readLongOrNull(offsets[2]),
    key: reader.readStringOrNull(offsets[3]) ?? '',
    stringValue: reader.readStringOrNull(offsets[4]),
    updatedAt: reader.readLongOrNull(offsets[5]) ?? 0,
  );
  object.id = id;
  return object;
}

P _accountDataISARDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBoolOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _accountDataISARGetId(AccountDataISAR object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _accountDataISARGetLinks(AccountDataISAR object) {
  return [];
}

void _accountDataISARAttach(
    IsarCollection<dynamic> col, Id id, AccountDataISAR object) {
  object.id = id;
}

extension AccountDataISARByIndex on IsarCollection<AccountDataISAR> {
  Future<AccountDataISAR?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  AccountDataISAR? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<AccountDataISAR?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<AccountDataISAR?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(AccountDataISAR object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(AccountDataISAR object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<AccountDataISAR> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(List<AccountDataISAR> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension AccountDataISARQueryWhereSort
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QWhere> {
  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AccountDataISARQueryWhere
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QWhereClause> {
  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterWhereClause> keyEqualTo(
      String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'key',
        value: [key],
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterWhereClause>
      keyNotEqualTo(String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AccountDataISARQueryFilter
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QFilterCondition> {
  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      boolValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'boolValue',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      boolValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'boolValue',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      boolValueEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'boolValue',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'doubleValue',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'doubleValue',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doubleValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'doubleValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'doubleValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      doubleValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'doubleValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'intValue',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'intValue',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'intValue',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'intValue',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'intValue',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      intValueBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'intValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stringValue',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stringValue',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stringValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stringValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stringValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stringValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      stringValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stringValue',
        value: '',
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      updatedAtEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      updatedAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      updatedAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterFilterCondition>
      updatedAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AccountDataISARQueryObject
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QFilterCondition> {}

extension AccountDataISARQueryLinks
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QFilterCondition> {}

extension AccountDataISARQuerySortBy
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QSortBy> {
  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boolValue', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByBoolValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boolValue', Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doubleValue', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByDoubleValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doubleValue', Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intValue', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intValue', Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByStringValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByStringValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AccountDataISARQuerySortThenBy
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QSortThenBy> {
  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boolValue', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByBoolValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boolValue', Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doubleValue', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByDoubleValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doubleValue', Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intValue', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByIntValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intValue', Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy> thenByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByStringValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByStringValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stringValue', Sort.desc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension AccountDataISARQueryWhereDistinct
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QDistinct> {
  QueryBuilder<AccountDataISAR, AccountDataISAR, QDistinct>
      distinctByBoolValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'boolValue');
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QDistinct>
      distinctByDoubleValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doubleValue');
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QDistinct>
      distinctByIntValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intValue');
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QDistinct> distinctByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QDistinct>
      distinctByStringValue({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stringValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountDataISAR, AccountDataISAR, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension AccountDataISARQueryProperty
    on QueryBuilder<AccountDataISAR, AccountDataISAR, QQueryProperty> {
  QueryBuilder<AccountDataISAR, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AccountDataISAR, bool?, QQueryOperations> boolValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'boolValue');
    });
  }

  QueryBuilder<AccountDataISAR, double?, QQueryOperations>
      doubleValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doubleValue');
    });
  }

  QueryBuilder<AccountDataISAR, int?, QQueryOperations> intValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intValue');
    });
  }

  QueryBuilder<AccountDataISAR, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<AccountDataISAR, String?, QQueryOperations>
      stringValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stringValue');
    });
  }

  QueryBuilder<AccountDataISAR, int, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
