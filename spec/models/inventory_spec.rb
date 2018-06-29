require 'rails_helper'

RSpec.describe Inventory, type: :model do
    it { should belong_to(:product) }
    it { should belong_to(:distribution_center) }

    it { should validate_presence_of(:available_amount) }
    it { should validate_presence_of(:reserved_amount) }
    
    it { should validate_numericality_of(:available_amount) }
    it { should_not allow_value(-1).for(:available_amount) }
    it { should allow_value(0).for(:available_amount) }
    
    it { should validate_numericality_of(:reserved_amount) }
    it { should_not allow_value(-1).for(:reserved_amount) }
    it { should allow_value(0).for(:reserved_amount) }
end
