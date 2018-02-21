RSpec.describe SimpleLock do
  it "has a version number" do
    expect(SimpleLock::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'validates the adapter respnds to appropriate methods' do
      valid_adapter = Object.new

      SimpleLock::ADAPTER_METHODS.each do |method|
        valid_adapter.define_singleton_method(method){ method }
      end

      expect do
        SimpleLock.configure do |config|
          config.adapter = valid_adapter
        end
      end.to_not raise_exception


      invalid_adapter = Object.new
      expect do
        SimpleLock.configure do |config|
          config.adapter = invalid_adapter
        end
      end.to raise_exception
    end
  end
end
