// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecipeCollection on Isar {
  IsarCollection<Recipe> get recipes => this.collection();
}

const RecipeSchema = CollectionSchema(
  name: r'Recipe',
  id: 8054415271972849591,
  properties: {
    r'displayDuration': PropertySchema(
      id: 0,
      name: r'displayDuration',
      type: IsarType.string,
    ),
    r'hasDescription': PropertySchema(
      id: 1,
      name: r'hasDescription',
      type: IsarType.string,
    ),
    r'hasHealthBenefit': PropertySchema(
      id: 2,
      name: r'hasHealthBenefit',
      type: IsarType.string,
    ),
    r'hasPreparationTime': PropertySchema(
      id: 3,
      name: r'hasPreparationTime',
      type: IsarType.long,
    ),
    r'id': PropertySchema(
      id: 4,
      name: r'id',
      type: IsarType.string,
    ),
    r'unlockedAt': PropertySchema(
      id: 5,
      name: r'unlockedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _recipeEstimateSize,
  serialize: _recipeSerialize,
  deserialize: _recipeDeserialize,
  deserializeProp: _recipeDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'id': IndexSchema(
      id: -3268401673993471357,
      name: r'id',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'id',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _recipeGetId,
  getLinks: _recipeGetLinks,
  attach: _recipeAttach,
  version: '3.1.0+1',
);

int _recipeEstimateSize(
  Recipe object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayDuration.length * 3;
  bytesCount += 3 + object.hasDescription.length * 3;
  bytesCount += 3 + object.hasHealthBenefit.length * 3;
  bytesCount += 3 + object.id.length * 3;
  return bytesCount;
}

void _recipeSerialize(
  Recipe object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.displayDuration);
  writer.writeString(offsets[1], object.hasDescription);
  writer.writeString(offsets[2], object.hasHealthBenefit);
  writer.writeLong(offsets[3], object.hasPreparationTime);
  writer.writeString(offsets[4], object.id);
  writer.writeDateTime(offsets[5], object.unlockedAt);
}

Recipe _recipeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Recipe(
    hasDescription: reader.readString(offsets[1]),
    hasHealthBenefit: reader.readString(offsets[2]),
    hasPreparationTime: reader.readLong(offsets[3]),
    id: reader.readString(offsets[4]),
    isarId: id,
    unlockedAt: reader.readDateTime(offsets[5]),
  );
  return object;
}

P _recipeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _recipeGetId(Recipe object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _recipeGetLinks(Recipe object) {
  return [];
}

void _recipeAttach(IsarCollection<dynamic> col, Id id, Recipe object) {
  object.isarId = id;
}

extension RecipeByIndex on IsarCollection<Recipe> {
  Future<Recipe?> getById(String id) {
    return getByIndex(r'id', [id]);
  }

  Recipe? getByIdSync(String id) {
    return getByIndexSync(r'id', [id]);
  }

  Future<bool> deleteById(String id) {
    return deleteByIndex(r'id', [id]);
  }

  bool deleteByIdSync(String id) {
    return deleteByIndexSync(r'id', [id]);
  }

  Future<List<Recipe?>> getAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndex(r'id', values);
  }

  List<Recipe?> getAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'id', values);
  }

  Future<int> deleteAllById(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'id', values);
  }

  int deleteAllByIdSync(List<String> idValues) {
    final values = idValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'id', values);
  }

  Future<Id> putById(Recipe object) {
    return putByIndex(r'id', object);
  }

  Id putByIdSync(Recipe object, {bool saveLinks = true}) {
    return putByIndexSync(r'id', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllById(List<Recipe> objects) {
    return putAllByIndex(r'id', objects);
  }

  List<Id> putAllByIdSync(List<Recipe> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'id', objects, saveLinks: saveLinks);
  }
}

extension RecipeQueryWhereSort on QueryBuilder<Recipe, Recipe, QWhere> {
  QueryBuilder<Recipe, Recipe, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RecipeQueryWhere on QueryBuilder<Recipe, Recipe, QWhereClause> {
  QueryBuilder<Recipe, Recipe, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> isarIdGreaterThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> isarIdLessThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> idEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'id',
        value: [id],
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterWhereClause> idNotEqualTo(String id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [id],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'id',
              lower: [],
              upper: [id],
              includeUpper: false,
            ));
      }
    });
  }
}

extension RecipeQueryFilter on QueryBuilder<Recipe, Recipe, QFilterCondition> {
  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> displayDurationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
      displayDurationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> displayDurationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> displayDurationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> displayDurationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> displayDurationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> displayDurationContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayDuration',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> displayDurationMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayDuration',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> displayDurationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayDuration',
        value: '',
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
      displayDurationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayDuration',
        value: '',
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasDescriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasDescriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hasDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasDescriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hasDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasDescriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hasDescription',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasDescriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hasDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasDescriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hasDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasDescriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hasDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasDescriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hasDescription',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasDescriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
      hasDescriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hasDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasHealthBenefitEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasHealthBenefit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
      hasHealthBenefitGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hasHealthBenefit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasHealthBenefitLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hasHealthBenefit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasHealthBenefitBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hasHealthBenefit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
      hasHealthBenefitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hasHealthBenefit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasHealthBenefitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hasHealthBenefit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasHealthBenefitContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hasHealthBenefit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasHealthBenefitMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hasHealthBenefit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
      hasHealthBenefitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasHealthBenefit',
        value: '',
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
      hasHealthBenefitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hasHealthBenefit',
        value: '',
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasPreparationTimeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasPreparationTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
      hasPreparationTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hasPreparationTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition>
      hasPreparationTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hasPreparationTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> hasPreparationTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hasPreparationTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'id',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'id',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'id',
        value: '',
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> unlockedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> unlockedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> unlockedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterFilterCondition> unlockedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RecipeQueryObject on QueryBuilder<Recipe, Recipe, QFilterCondition> {}

extension RecipeQueryLinks on QueryBuilder<Recipe, Recipe, QFilterCondition> {}

extension RecipeQuerySortBy on QueryBuilder<Recipe, Recipe, QSortBy> {
  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByDisplayDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayDuration', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByDisplayDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayDuration', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByHasDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDescription', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByHasDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDescription', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByHasHealthBenefit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHealthBenefit', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByHasHealthBenefitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHealthBenefit', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByHasPreparationTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPreparationTime', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByHasPreparationTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPreparationTime', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> sortByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension RecipeQuerySortThenBy on QueryBuilder<Recipe, Recipe, QSortThenBy> {
  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByDisplayDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayDuration', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByDisplayDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayDuration', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByHasDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDescription', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByHasDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasDescription', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByHasHealthBenefit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHealthBenefit', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByHasHealthBenefitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasHealthBenefit', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByHasPreparationTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPreparationTime', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByHasPreparationTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasPreparationTime', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.asc);
    });
  }

  QueryBuilder<Recipe, Recipe, QAfterSortBy> thenByUnlockedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockedAt', Sort.desc);
    });
  }
}

extension RecipeQueryWhereDistinct on QueryBuilder<Recipe, Recipe, QDistinct> {
  QueryBuilder<Recipe, Recipe, QDistinct> distinctByDisplayDuration(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayDuration',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByHasDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasDescription',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByHasHealthBenefit(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasHealthBenefit',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByHasPreparationTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasPreparationTime');
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'id', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Recipe, Recipe, QDistinct> distinctByUnlockedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedAt');
    });
  }
}

extension RecipeQueryProperty on QueryBuilder<Recipe, Recipe, QQueryProperty> {
  QueryBuilder<Recipe, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<Recipe, String, QQueryOperations> displayDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayDuration');
    });
  }

  QueryBuilder<Recipe, String, QQueryOperations> hasDescriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasDescription');
    });
  }

  QueryBuilder<Recipe, String, QQueryOperations> hasHealthBenefitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasHealthBenefit');
    });
  }

  QueryBuilder<Recipe, int, QQueryOperations> hasPreparationTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasPreparationTime');
    });
  }

  QueryBuilder<Recipe, String, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Recipe, DateTime, QQueryOperations> unlockedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedAt');
    });
  }
}
