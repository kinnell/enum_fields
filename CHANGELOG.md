# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [X.X.X] - YYYY-MM-DD

- Extract out Configuration to define global configuration for all enum fields
- Rename `validate` option to `validatable` to better reflect its purpose
- Rename `scope` option to `scopeable` to better reflect its purpose
- Rename `allow_nil` option to `nullable` to better reflect its purpose
- Add `inquirable` option to control the generation of inquiry methods
- Polymorphic validation now respects `nullable` option and falls back to the association's `optional` setting
- Update release script to keep CHANGELOG.md up to date
- Add Continuous Integration suite to run tests and style checks

## [0.3.2] - 2026-03-08

- Restored CHANGELOG.md file

## [0.3.1] - 2026-03-08

- Release script to simplify gem deployment

## [0.3.0] - 2026-03-08

- Virtual attribute support — enum metadata, property, and inquiry methods now work against user-defined methods that aren't backed by a database column
- `scope: false` option to skip scope generation (required for virtual attributes, but useful independently)

## [0.2.1] - 2026-02-25

- Flexibility to array definitions, supporting more input formats

## [0.2.0] - 2026-02-24

- Namespace support for standalone enum field registration via `EnumFields.namespace(:name) { enum_field ... }`, decoupling definitions from ActiveRecord models
- `EnumFields.catalog` method for a sorted, serialization-friendly view of all registered definitions across model and standalone namespaces

## [0.1.2] - 2026-02-20

- Global `EnumFields::Registry` for cross-model enum field lookup and introspection

## [0.1.1] - 2026-02-02

- Polymorphic association resolution now falls back to finding by value when key lookup fails

## [0.1.0] - 2026-01-27

- `validate: false` option to disable validations on an enum field
- Validation support for columns used in polymorphic associations

## [0.0.5] - 2026-01-03

- Class-level value accessors for enum field definitions

## [0.0.4] - 2025-11-19

- `enum_fields_metadata` now returns `HashWithIndifferentAccess` instead of a plain hash

## [0.0.3] - 2025-11-19

- `enum_fields_metadata` instance method for accessing field metadata on model instances
- Extracted core interface functionality into separate `Base` module

## [0.0.2] - 2025-11-19

- `enum_field?` class method to check whether a given attribute is a registered enum field

## [0.0.1] - 2025-11-17

- Initial release with core `enum_field` DSL
- Hash and array definition formats
- Column override support
- Additional properties on enum values
- Inclusion validations
- Inquiry methods, property accessors, and human-readable labels
