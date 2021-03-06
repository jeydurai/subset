require 'subset/connector'

#= Contains functionalities of reading data
module Reader

    #== Contains reading functionalities of MongoDB
    class Mongo < Connector::MongoConnector
        attr_reader :data

        def initialize(coll_name: 'ent_dump_from_finance', db_name: 'ccsdm', host: 'localhost', port: '27017')
            super(coll_name: coll_name, db_name: db_name, host: host, port: port)
            @data = []
        end

        # Reads the data by running aggregation query
        def agg_each qry
            raise "[Error]: Aggregation query object is empty" unless qry
            rec = 0
            @coll.aggregate(qry).each do |doc|
                rec += 1
                yield doc, rec
            end
        end

        def agg_count qry
            @coll.aggregate(qry).count
        end

        public :agg_each, :agg_count

    end

end
