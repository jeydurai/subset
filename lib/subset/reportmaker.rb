require 'subset/reader'
require 'subset/writer'
require 'subset/querymaker'
require 'awesome_print'

#= Generates the reports
class ReportMaker < QueryMaker::Mongo

    def initialize(opts)
        super(opts)
        @past_years = opts[:inc_years]
        if @past_years
            @past_years = opts[:inc_years].to_i 
            @years = get_years
        end
        @reader = Reader::Mongo.new()
        @file_name = make_file_name opts[:year], opts[:quarter], opts[:month], opts[:week]
        @writer = FileWriter::Excel.new(@file_name)
    end
    
    # Based on past_years parameter, it makes years
    def get_years
        year = slice_year
        till_year = year.to_i - @past_years
        years = []
        year.to_i.downto(till_year) { |y| years << y }
        years
    end
    
    # Slices out the year from period options
    def slice_year
        if @year
            @year
        elsif @quarter
            @quarter[0, 4]
        elsif @month
            @month[0, 4]
        elsif @week
            @week[0, 4]
        else
            nil
        end
    end

    # Makes file name from options parameters so as to write as that file
    def make_file_name yr, qtr, mth, wk
        name = 'Booking_Summary'
        if yr
            name = "#{name}_#{yr}"
        elsif qtr
            name = "#{name}_#{qtr}"
        elsif mth
            name = "#{name}_#{mth}"
        elsif wk
            name = "#{name}_#{wk}"
        else
            raise "[Error]: Could not generate a file name"
        end
        name = "#{name}.xlsx"
        name
    end

    # Reads the data from MongoDB
    def read_and_write header_flag
        agg_qry = [ match_query, group_all, project_all ]
        @reader.agg_each(agg_qry) do |doc, i|
            data = doc.clone
            data['Year'] = data['Quarter'][0, 4]
            if data['Book_Adj_Code'] =~ /^L/i
                data['Cloud Flag'] = 'Y' 
            else
                data['Cloud Flag'] = 'N'
            end
            header = data.keys 
            if header_flag
                @writer.write_header header
                header_flag = false
            end
            @writer.write_data data
        end
    end

    # Makes the report
    def execute
        if @past_years
            @years.each_with_index do |year, i|
                puts "Querying and Writing #{year} data..."
                h_flag = false
                set_correct_period(year.to_s)
                h_flag = true if i == 0
                read_and_write(h_flag)
            end
        else
            read_and_write(true)
        end
        @writer.save
    end

    def set_correct_period year
        if @year
            @year = year
        elsif @quarter
            @quarter = year + slice_nonyear_string(@quarter)
        elsif @month
            @month = year + slice_nonyear_string(@month)
        elsif @week
            @week = year + slice_nonyear_string(@week)
        end
    end

    def slice_nonyear_string period
        len = period.length
        count = len - 4
        period[4, count]
    end

    private :make_file_name, :get_years, :slice_year, :read_and_write, 
        :set_correct_period, :slice_nonyear_string
    public :execute
    
end
