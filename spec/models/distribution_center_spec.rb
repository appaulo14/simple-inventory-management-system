require 'rails_helper'

RSpec.describe DistributionCenter, type: :model do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:location) }
end
