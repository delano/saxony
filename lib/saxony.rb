require 'nokogiri'
require 'stringio'

class Saxony 
  class Document < Nokogiri::XML::SAX::Document
    attr_reader :total_count, :granularity
    def initialize(element, granularity, &processor)
      @start_time = Time.now
      @element, @processor = element, processor
      @granularity, @total_count = granularity, 0
      reset
    end
    def elapsed_time
      Time.now - @start_time
    end
    def start_element(element, attributes)
      if element == @element.to_s
        @count += 1 and @total_count += 1
        @collect = true 
      end
      @xml << to_otag(element, attributes) if @collect
    end
    def characters(text)
      @xml << text if @collect
    end
    def cdata_block(text)
      @xml << to_cdata(text) if @collect
    end
    def end_element(element)
      @xml << to_ctag(element) if @collect
      if element == @element.to_s
        @collect = false
        @xml << $/
        process_objects if @count >= @granularity
      end
    end
    def end_document
      process_objects unless @xml.empty?
    end
    def process_objects
      @xml.rewind
      @xml = "<SAXONYDOC>#{@xml.read}</SAXONYDOC>"
      self.instance_eval &@processor
      reset
    end
    private
    def doc
      @doc ||= Nokogiri::XML(@xml)
    end
    def reset
      @xml, @count, @doc, @start_time = StringIO.new, 0, nil, Time.now
    end
    def to_otag(name, attributes=[])
      t = name
      "<#{t}>"
    end
    def to_ctag(name)
      "</#{name}>"
    end
    def to_cdata(text)
      "<![CDATA[#{text}]]>"
    end
  end
  
  attr_reader :granularity, :element
  def initialize(element, granularity=1000)
    @element, @granularity = element, granularity
  end
    
  def parse *sources, &blk
    sources.flatten!
    sources.each do |src|
      saxdoc = Saxony::Document.new @element, @granularity, &blk
      parser = Nokogiri::XML::SAX::Parser.new(saxdoc)
      xml = (String === src && File.exists?(src)) ? File.open(src) : src
      parser.parse xml
    end
  end
end

#STDERR.print '.' if @samples % 5000 == 0

if $0 == __FILE__
  sax = Saxony.new :Listing, 1000

  sax.parse ARGV do
    p [total_count, doc.xpath("//Listing").size, elapsed_time.to_f]
#    p 
  end
end

