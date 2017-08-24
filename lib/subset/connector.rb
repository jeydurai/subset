#= Module containing connectors to databases

module Connector

    #== Defines MongoDB connection properties
    class MongoConnector
        require 'mongo'

        attr_accessor :client, :coll, :coll_name, :db_name, :host, :port

        def initialize(coll_name: 'ent_dump_from_finance', db_name: 'ccsdm', host: 'localhost', port: '27017')
            @coll_name, @db_name, @host, @port = coll_name, db_name, host, port
            Mongo::Logger.logger.level = Logger::WARN
            @conn_str = "#{@host}:#{@port}" 
            @client = Mongo::Client.new([@conn_str], :database => @db_name)
            @coll = @client[@coll_name]
        end

        # Returns the number of matched recs
        def recs(qry: {})
            @coll.find(qry).count
        end

        def collection_exists?
            recs > 0
        end

        def field_exists? field
            @coll.find({}).projection({ '_id' => 0 }).limit(1).collect { |doc| doc }.keys.include? field
        end

        public :recs, :collection_exists?, :field_exists?

    end


    class ExcelWriteConnector
        require 'rubyXL'

        attr_accessor :wb, :ws

        def initialize(path)
            @path = path
            @wb = RubyXL::Workbook.new
            @ws = @wb.worksheets[0]
        end

    end

end
