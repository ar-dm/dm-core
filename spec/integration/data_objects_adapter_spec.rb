require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

if HAS_SQLITE3
  describe DataMapper::Adapters::DataObjectsAdapter do
    describe 'a connection' do
      before :each do
        @adapter = DataMapper::Adapters::Sqlite3Adapter.new(:sqlite3, Addressable::URI.parse('sqlite3::memory:'))
        @transaction = DataMapper::Transaction.new(@adapter)

        @command = mock('command', :execute_non_query => nil)
        @connection = mock('connection', :create_command => @command)
        DataObjects::Connection.stub!(:new).and_return(@connection)
      end

      it 'should close automatically when no longer needed' do
        @connection.should_receive(:close)
        @adapter.execute('SELECT 1')
      end

      it 'should not close when a current transaction is active' do
        @connection.should_receive(:create_command).with('SELECT 1').twice.and_return(@command)
        @connection.should_not_receive(:close)

        @transaction.begin
        @transaction.within do
          @adapter.execute('SELECT 1')
          @adapter.execute('SELECT 1')
        end
      end
    end
  end
end
