#= Module that constructs MongoDB queries

module QueryMaker

    #== MongoDB Query generator
    class Mongo

        attr_writer :year

        def initialize(opts)
            @sl3, @sl4, @sl5, @sl6 = opts[:sl3], opts[:sl4], opts[:sl5], opts[:sl6] 
            @year, @quarter, @month, @week = opts[:year], opts[:quarter], opts[:month], opts[:week] 
            @service, @all = opts[:service], opts[:all]
            @sensitivity = opts[:sensitivity]
        end

        # 'sales_level_3' as MongoDB Match object
        def match_sl3
            @sl3 ? { 'sales_level_3' => @sl3 } : {}
        end

        # 'sales_level_4' as MongoDB Match object
        def match_sl4
            @sl4 ? { 'sales_level_4' => @sl4 } : {}
        end

        # 'sales_level_5' as MongoDB Match object
        def match_sl5
            @sl5 ? { 'sales_level_5' => @sl5 } : {}
        end

        # 'sales_level_6' as MongoDB Match object
        def match_sl6
            @sl6 ? { 'sales_level_6' => @sl6 } : {}
        end

        # Makes a consolidated match obj for business nodes 
        def match_sales_levels
            nodes = {}
            nodes.merge!(match_sl3)
            nodes.merge!(match_sl4)
            nodes.merge!(match_sl5)
            nodes.merge!(match_sl6)
            nodes
        end

        # 'fiscal_quarter_id' for year as MongoDB Match object
        def match_year
            @year ? { 'fiscal_quarter_id' => /^#{@year}/i } : {}
        end

        # 'fiscal_quarter_id' as MongoDB Match object
        def match_quarter
            @quarter ? { 'fiscal_quarter_id' => /#{@quarter}/i } : {}
        end

        # 'fiscal_period_id' for month as MongoDB Match object
        def match_month
            @month ? { 'fiscal_period_id' => @month.to_i } : {}
        end

        # 'fiscal_week_id' as MongoDB Match object
        def match_week
            @week ? { 'fiscal_week_id' => @week.to_i } : {}
        end

        # Makes a consolidated match obj for period nodes 
        def match_periods
            periods = {}
            periods.merge!(match_year)
            periods.merge!(match_quarter)
            periods.merge!(match_month)
            periods.merge!(match_week)
            periods
        end

        # 'services_indicator' - qualifies products/services MongoDB Match object
        def match_services_indicator
            return {} if @all
            @service ? { 'services_indicator' => 'Y' } : { 'services_indicator' => 'N' }
        end

        # Final match object 
        def match_query
            qry = {}
            qry.merge!(match_sales_levels)
            qry.merge!(match_periods)
            qry.merge!(match_services_indicator)
            { '$match' => qry }
        end

        # Generates Group by fields
        def groupby_fields
            ids = {}
            ids.merge!(groupby_periods)
            ids.merge!(groupby_nodes)
            { '_id' => ids }
        end

        # Prepares Periods group object
        def groupby_periods
            { 'fiscal_quarter_id' => '$fiscal_quarter_id' } 
        end

        # Prepares Nodes group object
        def groupby_nodes
            {
                'sales_level_3'      => '$sales_level_3',
                'sales_level_4'      => '$sales_level_4',
                'sales_level_5'      => '$sales_level_5',
                'sales_level_6'      => '$sales_level_6',
                'services_indicator' => '$services_indicator',
                'book_adj_code'      => '$bookings_adjustments_code'
            } 
        end

        # Prepares group object for 'Booking Net'
        def groupby_bookingnet
            { 'booking_net' => { '$sum' => '$booking_net' } } 
        end

        # Prepares group object for 'Base List'
        def groupby_baselist
            { 'base_list' => { '$sum' => '$tms_sales_allocated_bookings_base_list' } } 
        end

        # Prepares group object for 'Standard Cost'
        def groupby_standardcost
            { 'std_cost' => { '$sum' => '$standard_cost' } } 
        end

        # Generates Group by values 
        def groupby_values
            vals = {}
            vals.merge!(groupby_bookingnet)
            vals.merge!(groupby_baselist) unless @sensitivity >= 2
            vals.merge!(groupby_standardcost) unless @sensitivity >= 1
            vals
        end

        # Returns grouped fields for MongoDB aggregate query
        def group_all
            grp = {}
            grp.merge!(groupby_fields)
            grp.merge!(groupby_values)
            { '$group' => grp }
        end

        # Prepares Periods project object
        def project_periods
            { 'Quarter' => '$_id.fiscal_quarter_id' } 
        end

        # Prepares Nodes project object
        def project_nodes
            {
                'L3'            => '$_id.sales_level_3',
                'L4'            => '$_id.sales_level_4',
                'L5'            => '$_id.sales_level_5',
                'L6'            => '$_id.sales_level_6',
                'Services_Flag' => '$_id.services_indicator',
                'Book_Adj_Code' => '$_id.book_adj_code'
            } 
        end

        # Prepares project object for 'Booking Net'
        def project_bookingnet
            { 'BookingNet' => '$booking_net' } 
        end

        # Prepares project object for 'Base List'
        def project_baselist
            { 'BaseList' => '$base_list'  } 
        end

        # Prepares project object for 'Standard Cost'
        def project_standardcost
            { 'StdCost' => '$std_cost' } 
        end

        # Returns aggregate 'project' object
        def project_all
            prj = { '_id' => 0 }
            prj.merge!(project_periods)
            prj.merge!(project_nodes)
            prj.merge!(project_bookingnet)
            prj.merge!(project_baselist) unless @sensitivity >= 2
            prj.merge!(project_standardcost) unless @sensitivity >= 1
            { '$project' => prj }
        end

        private :match_sl3, :match_sl4, :match_sl5, :match_sl6,
            :match_year, :match_quarter, :match_month, :match_week,
            :groupby_periods, :groupby_nodes, :groupby_fields, :groupby_values, 
            :groupby_bookingnet, :groupby_bookingnet, :groupby_baselist, :groupby_standardcost,
            :project_periods, :project_nodes, :project_bookingnet, :project_bookingnet, 
            :project_baselist, :project_standardcost

        public :match_sales_levels, :match_periods, :match_services_indicator, :match_query,
            :group_all, :project_all

    end

end
