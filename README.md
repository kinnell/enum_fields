# EnumFields

Enhanced enum-like fields for ActiveRecord models with metadata support

## Requirements

- Ruby >= 2.7.6
- Rails >= 6.0 (ActiveRecord and ActiveSupport)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "enum_fields"
```

And then execute:

```bash
bundle install
```

## Usage

### Basic Setup

Include the `EnumFields` module in your `ApplicationRecord`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  include EnumFields

  self.abstract_class = true
end
```

Now all models inheriting from `ApplicationRecord` can use `enum_field`.

### Defining Enum Fields

#### Hash Definition (Recommended)

```ruby
class Campaign < ApplicationRecord
  enum_field :stage, {
    pending: {
      value: "pending",
      label: "Pending",
      icon: "clock",
      color: "yellow",
      tooltip: "Campaign is awaiting processing",
    },
    processing: {
      value: "processing",
      label: "Processing",
      icon: "cog",
      color: "blue",
      tooltip: "Campaign is being processed",
    },
    shipped: {
      value: "shipped",
      label: "Shipped",
      icon: "truck",
      color: "green",
      tooltip: "Campaign has been shipped",
    },
    delivered: {
      value: "delivered",
      label: "Delivered",
      icon: "check",
      color: "green",
      tooltip: "Campaign has been delivered",
    },
  }
end
```

#### Array Definition (Simple)

```ruby
class Task < ApplicationRecord
  enum_field :priority, ["low", "medium", "high"]
end
```

This automatically generates:

```ruby
{
  low: {
    value: "low",
    label: "low",
  },
  medium: {
    value: "medium",
    label: "medium",
  },
  high: {
    value: "high",
    label: "high",
  },
}
```

### Generated Methods

For an enum field defined as:

```ruby
class Campaign < ApplicationRecord
  enum_field :stage, {
    draft: {
      value: "draft",
      label: "Draft",
      icon: "file",
      color: "gray",
    },
    scheduled: {
      value: "scheduled",
      label: "Scheduled",
      icon: "calendar",
      color: "blue",
    },
    completed: {
      value: "completed",
      label: "Completed",
      icon: "check",
      color: "green",
    },
  }
end
```

#### Class Methods

```ruby
# Returns the definitions as an HashWithIndifferentAccess
Campaign.stages

# Returns the count of definitions
Campaign.stages_count # 3

# Returns the values of the definitions
Campaign.stages_values # ["draft", "scheduled", "completed"]

# Returns the options for form helpers
Campaign.stages_options # [["Draft", "draft"], ["Scheduled", "scheduled"], ["Completed", "completed"]]

# Returns the value for a specific key
Campaign.draft_stage_value     # "draft"
Campaign.scheduled_stage_value # "scheduled"
Campaign.completed_stage_value # "completed"
```

#### Instance Getter/Setter

If the accessor name differs from the column name, getter and setter methods are defined for the accessor.

```ruby
campaign.stage # "draft"
campaign.stage = "scheduled"
campaign.stage # "scheduled"
```

- `campaign.stage` - Get the current stage value
- `campaign.stage = "scheduled"` - Set the stage value

#### Metadata Methods

The gem automatically creates accessor methods for all properties defined in your enum definitions.

- `value` (required) - The actual value stored in the database
- `label` (auto-generated if not provided) - A human-readable label

Any additional properties you define (like `icon`, `color`, `tooltip`, etc.) will also get dedicated accessor methods automatically.

```ruby
# Returns the full metadata hash for current value
campaign.stage_metadata
# => { value: "draft", label: "Draft", icon: "file", color: "gray" }

# Access individual properties
campaign.stage_value # "draft"
campaign.stage_label # "Draft"
campaign.stage_icon  # "file"
campaign.stage_color # "gray"
```

#### Inquiry Methods

```ruby
# Returns true if the current value is "draft"
campaign.draft_stage?

# Returns true if the current value is "scheduled"
campaign.scheduled_stage?

# Returns true if the current value is "completed"
campaign.completed_stage?
```

#### Scopes

```ruby
# Returns all campaigns with draft stage
Campaign.draft_stage

# Returns all campaigns with scheduled stage
Campaign.scheduled_stage

# Returns all campaigns with completed stage
Campaign.completed_stage
```

#### Validation

Automatically validates that the column value is included in the defined values (with `allow_nil: true`).

### Options

#### `column`

Map the accessor to a different database column name:

```ruby
enum_field :role, definitions, column: :user_role
```

#### `scope`

Controls whether query scopes are generated. Defaults to `true`. Set to `false` to skip scope generation:

```ruby
enum_field :speed, definitions, scope: false
```

#### `validate`

Controls whether inclusion validation is added. Defaults to `true`. Set to `false` to skip validation:

```ruby
enum_field :speed, definitions, validate: false
```

### Virtual Attributes

`enum_field` works with computed/virtual attributes that aren't backed by a database column. Define a method on the model and use `scope: false` and `validate: false` since those features require a real column:

```ruby
class Segment < ApplicationRecord
  enum_field :size_category, {
    small: {
      value: "small",
      label: "Small (< 100)",
    },
    medium: {
      value: "medium",
      label: "Medium (< 1K)",
    },
    large: {
      value: "large",
      label: "Large (< 10K)",
    },
  }, scope: false, validate: false

  def size_category
    case profiles_count
    when ...100
      "small"
    when 100...1_000
      "medium"
    else
      "large"
    end
  end
end
```

All instance methods work as expected:

```ruby
segment.size_category           # "small"
segment.size_category_label     # "Small (< 100)"
segment.size_category_metadata  # { value: "small", label: "Small (< 100)" }
segment.small_size_category?    # true
```

Class methods (options, values, counts) also work normally:

```ruby
Segment.size_category_options # [["Small (< 100)", "small"], ["Medium (< 1K)", "medium"], ...]
Segment.size_category_values  # ["small", "medium", "large"]
```

### Custom Properties

You can add any custom properties to your definitions, and the gem will automatically create accessor methods for them:

```ruby
class Ticket < ApplicationRecord
  enum_field :priority, {
    low: {
      value: "low",
      label: "Low Priority",
      sla_hours: 72,
      notify_manager: false,
    },
    high: {
      value: "high",
      label: "High Priority",
      sla_hours: 4,
      notify_manager: true,
    },
  }
end

# Access custom properties directly via generated methods
ticket.priority_sla_hours      # 72
ticket.priority_notify_manager # false

# Or access via metadata hash
ticket.priority_metadata[:sla_hours]      # 72
ticket.priority_metadata[:notify_manager] # false
```

### Registry & Standalone Registration

When `enum_field` is used in a model, definitions are automatically registered under a namespace derived from the model class name (e.g., `Campaign` becomes `campaign`).

You can also register definitions directly, outside of models, using the `namespace` DSL:

```ruby
# config/initializers/enum_fields.rb
EnumFields.namespace(:basic) do
  enum_field :priority, {
    low: {
      value: "low",
      label: "Low",
    },
    medium: {
      value: "medium",
      label: "Medium",
    },
    high: {
      value: "high",
      label: "High",
    },
  }

  enum_field :status, {
    active: {
      value: "active",
      label: "Active",
    },
    inactive: {
      value: "inactive",
      label: "Inactive",
    },
  }
end
```

Access the raw registry:

```ruby
EnumFields.registry
# => { "basic" => { "priority" => { ... }, "status" => { ... } }, "campaign" => { ... } }
```

### Catalog

`EnumFields.catalog` returns all registered definitions with namespaces sorted alphabetically, each field's entries as an array of metadata hashes (keys stripped):

```ruby
EnumFields.catalog
# => {
#   "basic" => {
#     "priority" => [
#       {
#         "value" => "low",
#         "label" => "Low",
#       },
#       {
#         "value" => "medium",
#         "label" => "Medium",
#       },
#       {
#         "value" => "high",
#         "label" => "High",
#       },
#     ],
#     "status" => [
#       {
#         "value" => "active",
#         "label" => "Active",
#       },
#       {
#         "value" => "inactive",
#         "label" => "Inactive",
#       },
#     ],
#   },
#   "campaign" => {
#     "stage" => [
#       {
#         "value" => "pending",
#         "label" => "Pending",
#         "icon" => "clock",
#         "color" => "yellow",
#       },
#       {
#         "value" => "processing",
#         "label" => "Processing",
#         "icon" => "cog",
#         "color" => "blue",
#       },
#       {
#         "value" => "shipped",
#         "label" => "Shipped",
#         "icon" => "truck",
#         "color" => "green",
#       },
#       {
#         "value" => "delivered",
#         "label" => "Delivered",
#         "icon" => "check",
#         "color" => "green",
#       },
#     ],
#   },
# }
```

## Development

After checking out the repo, run:

```bash
bundle install
```

Run the test suite:

```bash
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kinnell/enum_fields.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
