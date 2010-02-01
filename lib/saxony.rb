require 'nokogiri'
require 'stringio'


class Saxony 
  VERSION = "0.1.1".freeze unless defined?(Saxony::VERSION)
  
  class Document < Nokogiri::XML::SAX::Document
    attr_reader :total_count, :granularity
    def initialize(element, granularity, &processor)
      @root_element = nil
      @start_time = Time.now
      @element, @processor = element, processor
      @granularity, @total_count = granularity, 0
      reset
    end

    def elapsed_time
      Time.now - @start_time
    end
    def xml
      @xml ||= "<#{@root_element}>#{@buffer.string}</#{@root_element}>"
    end
    def doc
      @doc ||= Nokogiri::XML(xml)
    end

    def start_element(element, attributes)
      if element == @element.to_s
        @count += 1 and @total_count += 1
        @collect = true 
        @root_element = 'SAXONYDOC' if @root_element.nil?
      else
        @root_element = element if @root_element.nil?
      end
      @buffer << to_otag(element, attributes) if @collect
    end
    def characters(text)
      @buffer << text if @collect
    end
    def cdata_block(text)
      @buffer << to_cdata(text) if @collect
    end
    def end_element(element)
      @buffer << to_ctag(element) if @collect
      if element == @element.to_s
        @collect = false
        @buffer << $/
        process_objects if @granularity > 0 && @count >= @granularity
      end
    end
    def end_document
      process_objects unless @buffer.pos <= 0
    end

  private
    def process_objects
      self.instance_eval &@processor
      reset
    end
    def reset
      @xml = nil
      @buffer, @count, @doc, @start_time = StringIO.new, 0, nil, Time.now
    end
    def to_otag(name, attributes=[])
      t = name
      unless attributes.empty?
        attributes.each_with_index do |v,index|
          next if index % 2 > 0
          t << %Q( #{v}="#{attributes[index+1]}")
        end
      end
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
  
  # * sources can be a list of file paths, IO objects, or XML strings
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
  sax.parse DATA do
    #doc.xpath("//Listing").each do |obj|
    #end
    p [total_count, doc.xpath("//Listing").size, elapsed_time.to_f]
#    p 

  end
end


