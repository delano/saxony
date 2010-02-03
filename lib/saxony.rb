require 'nokogiri'
require 'stringio'


class Saxony 
  VERSION = "0.3.2".freeze unless defined?(Saxony::VERSION)
  
  class Document < Nokogiri::XML::SAX::Document
    attr_accessor :path
    attr_reader :total_count, :granularity, :suffix
    def initialize(element, granularity, suffix=nil, idx=nil, &processor)
      @root_element = nil
      @suffix = suffix || '-saxony'
      @start_time = Time.now
      @element, @processor, @idx = element, processor, idx
      @granularity, @total_count = granularity, 0
      reset
    end
    def idx
      @idx ||= Thread.current.object_id
    end
    def fh
      @path.split
      @fh ||= File.open([path, @suffix].join('-'), 'w')
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
      fh.puts $/, "</#{@root_element}>"
      fh.close
    end

  private
    def process_objects
      unless @started
        puts "#{idx}: #{fh.path}"
        fh.puts "<#{@root_element}>" 
        @started = true
      end
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
  
  attr_reader :opts, :total_count
  def initialize(opts={})
    @opts = opts
    @total_count = 0
  end
  
  # * sources can be a list of file paths, IO objects, or XML strings
  def parse *sources, &blk
    sources.flatten!
    sources.each do |src|
      saxdoc = Saxony::Document.new @opts[:element], @opts[:batch], @opts[:suffix], &blk
      parser = Nokogiri::XML::SAX::Parser.new(saxdoc)
      if (String === src && File.exists?(src)) 
        xml = File.open(src) 
        saxdoc.path = src
      else
        xml = src
        saxdoc.path = src.class
      end
      parser.parse xml
      @total_count += saxdoc.total_count
    end
  end
  
  def Saxony.fork(paths, opts={}, &logic)
    opts = {
      :procs => 2,
      :batch => 1000
    }.merge! opts
    paths.flatten!
    sax = Saxony.new opts
    if opts[:procs] > 1
      path_chunks = paths.chunk(opts[:procs])
      opts[:procs].times do |idx|
        proc_paths = path_chunks[idx]
        pid = Kernel.fork do
          sax.parse *proc_paths, &logic
        end
        puts "PID #{pid} (#{idx+1}/#{opts[:procs]}): #{proc_paths.join(', ')}"
      end
    else
      sax.parse *paths, &logic
    end
    
  end
end

class Array
  def saxony_chunk(number_of_chunks)
    chunks = (1..number_of_chunks).collect { [] }
    while self.any?
      chunks.each do |a_chunk|
        a_chunk << self.shift if self.any?
      end
    end
    chunks
  end
  alias_method :chunk, :saxony_chunk unless method_defined? :chunk
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


