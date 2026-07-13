# frozen_string_literal: true

RSpec.describe EnumFields::VERSION do
  let(:output) { EnumFields::VERSION }

  it "uses semantic version format" do
    expect(output).to match(%r{\A[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\z})
  end
end
