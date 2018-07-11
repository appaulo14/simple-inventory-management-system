shared_examples_for 'it validates the amount attribute' do
    it 'should validate presence.' do
        @it.amount = nil
        expect(@it.valid?).to eq(false)
    end
    
    it 'should be valid when 1' do
        @it.amount = 1
        expect(@it.valid?).to eq(true)
    end
    
    it 'should not be valid when negative' do
        @it.amount = -1
        expect(@it.valid?).to eq(false)
    end
    
    it 'should not be valid when 0' do
        @it.amount = -1
        expect(@it.valid?).to eq(false)
    end 
end

shared_examples_for 'it validates the inventory_item attribute' do
    it 'should validate presence.' do
        @it.inventory_item = nil
        expect(@it.valid?).to eq(false)
    end
end