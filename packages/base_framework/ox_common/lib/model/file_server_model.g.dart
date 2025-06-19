// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_server_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFileServerModelCollection on Isar {
  IsarCollection<FileServerModel> get fileServerModels => this.collection();
}

const FileServerModelSchema = CollectionSchema(
  name: r'FileServerModel',
  id: 4859175782050046534,
  properties: {
    r'accessKey': PropertySchema(
      id: 0,
      name: r'accessKey',
      type: IsarType.string,
    ),
    r'bucketName': PropertySchema(
      id: 1,
      name: r'bucketName',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'pubkey': PropertySchema(
      id: 3,
      name: r'pubkey',
      type: IsarType.string,
    ),
    r'secretKey': PropertySchema(
      id: 4,
      name: r'secretKey',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 5,
      name: r'type',
      type: IsarType.byte,
      enumMap: _FileServerModeltypeEnumValueMap,
    ),
    r'url': PropertySchema(
      id: 6,
      name: r'url',
      type: IsarType.string,
    )
  },
  estimateSize: _fileServerModelEstimateSize,
  serialize: _fileServerModelSerialize,
  deserialize: _fileServerModelDeserialize,
  deserializeProp: _fileServerModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _fileServerModelGetId,
  getLinks: _fileServerModelGetLinks,
  attach: _fileServerModelAttach,
  version: '3.1.0+1',
);

int _fileServerModelEstimateSize(
  FileServerModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.accessKey.length * 3;
  bytesCount += 3 + object.bucketName.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.pubkey.length * 3;
  bytesCount += 3 + object.secretKey.length * 3;
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _fileServerModelSerialize(
  FileServerModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accessKey);
  writer.writeString(offsets[1], object.bucketName);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.pubkey);
  writer.writeString(offsets[4], object.secretKey);
  writer.writeByte(offsets[5], object.type.index);
  writer.writeString(offsets[6], object.url);
}

FileServerModel _fileServerModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FileServerModel(
    accessKey: reader.readStringOrNull(offsets[0]) ?? '',
    bucketName: reader.readStringOrNull(offsets[1]) ?? '',
    id: id,
    name: reader.readStringOrNull(offsets[2]) ?? '',
    pubkey: reader.readStringOrNull(offsets[3]) ?? '',
    secretKey: reader.readStringOrNull(offsets[4]) ?? '',
    type: _FileServerModeltypeValueEnumMap[reader.readByteOrNull(offsets[5])] ??
        FileServerType.nip96,
    url: reader.readString(offsets[6]),
  );
  return object;
}

P _fileServerModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 2:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 3:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 4:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 5:
      return (_FileServerModeltypeValueEnumMap[reader.readByteOrNull(offset)] ??
          FileServerType.nip96) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FileServerModeltypeEnumValueMap = {
  'nip96': 0,
  'blossom': 1,
  'minio': 2,
};
const _FileServerModeltypeValueEnumMap = {
  0: FileServerType.nip96,
  1: FileServerType.blossom,
  2: FileServerType.minio,
};

Id _fileServerModelGetId(FileServerModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fileServerModelGetLinks(FileServerModel object) {
  return [];
}

void _fileServerModelAttach(
    IsarCollection<dynamic> col, Id id, FileServerModel object) {
  object.id = id;
}

extension FileServerModelQueryWhereSort
    on QueryBuilder<FileServerModel, FileServerModel, QWhere> {
  QueryBuilder<FileServerModel, FileServerModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FileServerModelQueryWhere
    on QueryBuilder<FileServerModel, FileServerModel, QWhereClause> {
  QueryBuilder<FileServerModel, FileServerModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FileServerModel, FileServerModel, QAfterWhereClause>
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
} 