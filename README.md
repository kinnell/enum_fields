# EnumFields

Enhanced enum-like fields for ActiveRecord models with metadata support

## Requirements

- Ruby >= 2.7.6
- Rails >= 6.0 (ActiveRecord and ActiveSupport)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'enum_fields'
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
      value: 'pending',
      label: 'Pending',
      icon: 'clock',
      color: 'yellow',
      tooltip: 'Campaign is awaiting processing',
    },
    processing: {
      value: 'processing',
      label: 'Processing',
      icon: 'cog',
      color: 'blue',
      tooltip: 'Campaign is being processed',
    },
    shipped: {
      value: 'shipped',
      label: 'Shipped',
      icon: 'truck',
      color: 'green',
      tooltip: 'Campaign has been shipped',
    },
    delivered: {
      value: 'delivered',
      label: 'Delivered',
      icon: 'check',
      color: 'green',
      tooltip: 'Campaign has been delivered',
    },
  }
end
```

#### Array Definition (Simple)

```ruby
class Task < ApplicationRecord
  enum_field :priority, ['low', 'medium', 'high']
end
```

This automatically generates:

```ruby
{
  low: {
    value: 'low',
    label: 'low',
  },
  medium: {
    value: 'medium',
    label: 'medium',
  },
  high: {
    value: 'high',
    label: 'high',
  },
}
```

#### Custom Column Mapping

If your accessor name differs from your column name:

```ruby
class User < ApplicationRecord
  enum_field :role, definitions, column: :user_role
end
```

### Generated Methods

For an enum field defined as:

```ruby
class Campaign < ApplicationRecord
  enum_field :stage, {
    draft: {
      value: 'draft',
      label: 'Draft',
      icon: 'file',
      color: 'gray',
    },
    scheduled: {
      value: 'scheduled',
      label: 'Scheduled',
      icon: 'calendar',
      color: 'blue',
    },
    completed: {
      value: 'completed',
      label: 'Completed',
      icon: 'check',
      color: 'green',
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
Campaign.stages_values # ['draft', 'scheduled', 'completed']

# Returns the options for form helpers
Campaign.stages_options # [['Draft', 'draft'], ['Scheduled', 'scheduled'], ['Completed', 'completed']]

# Returns the value for a specific key
Campaign.draft_stage_value     # 'draft'
Campaign.scheduled_stage_value # 'scheduled'
Campaign.completed_stage_value # 'completed'
```

#### Instance Getter/Setter

If the accessor name differs from the column name, getter and setter methods are defined for the accessor.

```ruby
campaign.stage # 'draft'
campaign.stage = 'scheduled'
campaign.stage # 'scheduled'
```

- `campaign.stage` - Get the current stage value
- `campaign.stage = 'scheduled'` - Set the stage value

#### Metadata Methods

The gem automatically creates accessor methods for all properties defined in your enum definitions.

- `value` (required) - The actual value stored in the database
- `label` (auto-generated if not provided) - A human-readable label

Any additional properties you define (like `icon`, `color`, `tooltip`, etc.) will also get dedicated accessor methods automatically.

```ruby
# Returns the full metadata hash for current value
campaign.stage_metadata
# => { value: 'draft', label: 'Draft', icon: 'file', color: 'gray' }

# Access individual properties
campaign.stage_value # 'draft'
campaign.stage_label # 'Draft'
campaign.stage_icon  # 'file'
campaign.stage_color # 'gray'
```

#### Inquiry Methods

```ruby
# Returns true if the current value is 'draft'
campaign.draft_stage?

# Returns true if the current value is 'scheduled'
campaign.scheduled_stage?

# Returns true if the current value is 'completed'
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

### Custom Properties

You can add any custom properties to your definitions, and the gem will automatically create accessor methods for them:

```ruby
class Ticket < ApplicationRecord
  enum_field :priority, {
    low: {
      value: 'low',
      label: 'Low Priority',
      sla_hours: 72,
      notify_manager: false,
    },
    high: {
      value: 'high',
      label: 'High Priority',
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
