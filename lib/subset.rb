require "subset/version"
require 'subset/reportmaker'

module Subset

    def self.run(opts)
        validate_options opts
        sensitivity = validate_sensitivity opts
        options = {
            :sl3         => opts[:sl3],
            :sl4         => opts[:sl4],
            :sl5         => opts[:sl5],
            :sl6         => opts[:sl6],
            :year        => opts[:year],
            :quarter     => opts[:quarter],
            :month       => opts[:month],
            :week        => opts[:week],
            :inc_years   => opts[:inc_years],
            :sensitivity => sensitivity,
            :service     => opts[:service],
            :all         => opts[:all],
        }
        maker = ReportMaker.new(options)
        maker.execute
    end

    def self.validate_options opts
        unless opts[:year] or opts[:quarter] or opts[:month] or opts[:week]
            puts "[Error]: Financial year/quarter/month/week must be given"
            exit
        end
    end

    def self.validate_sensitivity opts
        return 0 unless opts[:sensitivity]
        opts[:sensitivity].to_i
    end
    
end
