require "subset/version"
require 'subset/reportmaker'

module Subset

    def self.run(opts)
        validate_options opts
        options = [
            :sl3 => opts[:sl3],
            :sl4 => opts[:sl4],
            :sl5 => opts[:sl5],
            :sl6 => opts[:sl6],
            :year => opts[:year],
            :quarter => opts[:quarter],
            :month => opts[:month],
            :week => opts[:week],
            :inc_years => opts[:inc_years],
            :sensitivity => opts[:sensitivity],
            :service => opts[:service],
            :all => opts[:all],
        ]
        maker = ReportMaker.new(options)
        maker.read
    end

    def self.validate_options opts
        unless opts[:year]
            puts "[Error]: Financial year must be given"
            exit
        end
    end
    
end
