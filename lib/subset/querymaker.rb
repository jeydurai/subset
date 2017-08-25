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
            @period_fields = [ 'fiscal_quarter_id' ]
            @nodes_fields = [ 'sales_level_3', 'sales_level_4', 'sales_level_5', 'sales_level_6', 
                              'services_indicator', 'bookings_adjustments_code' ]
            add_more_fields(opts[:more].to_i) if opts[:more]
        end

        # Adds more fields based on user's preference through 'more' option
        def add_more_fields more
            if more > 0
                [ 'product_classification', 'internal_business_entity_name', 'cbn_flag' ].each { |e| @nodes_fields << e }
            end
            if more > 1
                [ 'tbm', 'customer_name',  'partner_name' ].each { |e| @nodes_fields << e }
            end
            if more > 2
                [ 'fiscal_period_id' ].each { |e| @period_fields << e }
            end
            if more > 3
                [ 'fiscal_week_id' ].each { |e| @period_fields << e }
            end
            if more > 4
                [ 'product_id', 'sales_order_number_detail', 'erp_deal_id' ].each { |e| @nodes_fields << e }
            end
            raise "[Error]: 'More' option can not exeed 5" if more > 5
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
            ids.merge!(make_grp_prj_periods[0])
            ids.merge!(make_grp_prj_nodes[0])
            { '_id' => ids }
        end

        # Makes Aggregation Group and Project periods from an array
        def make_grp_prj_periods
            grp = {}; prj = {}
            @period_fields.each do |period|
                grp[period] = '$' + period
                prj[period] = '$_id.' + period
            end
            return [grp, prj]
        end

        # Makes Aggregation Group and Project objects from an array
        def make_grp_prj_nodes
            grp = {}; prj = {}
            @nodes_fields.each do |node|
                grp[node] = '$' + node
                prj[node] = '$_id.' + node
            end
            return [grp, prj]
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
            prj.merge!(make_grp_prj_periods[1])
            prj.merge!(make_grp_prj_nodes[1])
            prj.merge!(project_bookingnet)
            prj.merge!(project_baselist) unless @sensitivity >= 2
            prj.merge!(project_standardcost) unless @sensitivity >= 1
            { '$project' => prj }
        end

        private :match_sl3, :match_sl4, :match_sl5, :match_sl6,
            :match_year, :match_quarter, :match_month, :match_week,
            :groupby_fields, :groupby_values, :groupby_bookingnet, :groupby_bookingnet, 
            :groupby_baselist, :groupby_standardcost, :project_bookingnet, :project_bookingnet, 
            :project_baselist, :project_standardcost, :make_grp_prj_periods, :make_grp_prj_nodes, 
            :add_more_fields

        public :match_sales_levels, :match_periods, :match_services_indicator, :match_query,
            :group_all, :project_all

    end

end
