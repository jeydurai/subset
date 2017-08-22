require 'subset/reader'
require 'subset/querymaker'
require 'awesome_print'

#= Generates the reports
class ReportMaker < QueryMaker::Mongo

    def initialize(opts)
        super(opts)
        @reader = Reader::Mongo.new()
    end

    # Reads the data from MongoDB
    def read
        agg_qry = [ match_query, group_all, project_all ]
        ap agg_qry
    end
    
end
