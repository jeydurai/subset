require 'subset/connector'

#= Contains functionalities of writing data
module FileWriter

    #== Contains Excel writing functionalities
    class Excel < Connector::ExcelWriteConnector

        @@row = 0

        def initialize(path)
            super(path)
            @header = nil
        end

        # Writes the header/first row in the excel sheet
        def write_header header
            @header = header
            @header.each_with_index { |h, col| @ws.add_cell(@@row, col, h) }
        end

        # Writes the data in the excel sheet
        def write_data doc
            @@row += 1
            @header.each_with_index do |h, col|
                @ws.add_cell(@@row, col, doc[h])
            end 
        end

        # Save the file
        def save
            @wb.write(@path)
        end

        public :write_header, :write_data, :save

    end

end
