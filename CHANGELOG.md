# Changelog

## [0.0.1] - 2025-11-17

### Added

- Initial release of EnumFields gem
- Support for enum-like fields with metadata properties
- Array and Hash definition formats
- Automatic generation of:
  - Class methods (`<accessor>s`, `<accessor>s_count`, `<accessor>_values`, `<accessor>_options`)
  - Instance getter/setter methods (when accessor differs from column)
  - Metadata accessor methods (`<accessor>_metadata`)
  - Property accessor methods for all defined properties (`<accessor>_<property>`)
  - Inquiry methods (`<key>_<accessor>?`)
  - Scopes (`<key>_<accessor>`)
  - Validations (inclusion with `allow_nil: true`)
- Custom column mapping support via `column:` option
- Dynamic property method generation for custom properties

[0.0.1]: https://github.com/kinnell/enum_fields/releases/tag/v0.0.1
