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
  sax.parse ARGV do
    #doc.xpath("//Listing").each do |obj|
    #end
    p [total_count, doc.xpath("//Listing").size, elapsed_time.to_f]
#    p 

  end
end

__END__

<BusinessListings>
<Listing><ListingId>17</ListingId><DBID>16</DBID><BusName>&#39;A&#39; Company Military Surplus</BusName><BusNameFr>&#39;A&#39; Company Military Surplus</BusNameFr><Address>2240 Alberni Hwy</Address><City>Parksville</City><PstCode>V0R1M0</PstCode><Phone><Primary><Prefix>+1</Prefix><NPA>250</NPA><NXX>951</NXX><XNUM>0609</XNUM><DisplayNumber>250-951-0609</DisplayNumber></Primary><Other Type="Click2Call"><Prefix>+1</Prefix><NPA>250</NPA><NXX>951</NXX><XNUM>0609</XNUM><DisplayNumber>250-951-0609</DisplayNumber></Other></Phone>
<ListingKeys>D00007295080000465894</ListingKeys><ReportId>16</ReportId><Paid>Y</Paid><ListEntry><DirProv>BC</DirProv><DirCode>022000</DirCode><HdCode>00866400</HdCode><Channel>2</Channel><Rank>7</Rank><NormRank>0</NormRank><Placement Child="false">DPlus</Placement><Products><HS DirPlus="1HS"  true="Lang"  AdNo="EN"  13980461ab="Rank"  PrdCode="7"  WEBHS3="Colour"  Udac=""><Keywords><Classification><Heading HdCode="HdName"  00866400=""></Heading></Classification><Raw>OPEN 7 DAYS A WEEK CALL US FOR SPECIALS</Raw><HrsOpr>7days</HrsOpr></Keywords><Text><Line Num="Val"  1="OPEN 7 DAYS A WEEK"></Line>
<Line Num="Val"  2="CALL US FOR SPECIALS"></Line>
</Text></HS></Products>
</ListEntry><ListEntry><DirProv>BC</DirProv><DirCode>086494</DirCode><HdCode>00866400</HdCode><Channel>1</Channel><Rank>7</Rank><NormRank>0</NormRank><Placement Child="false">DPlus</Placement><Products><HS DirPlus="1HS"  true="Lang"  AdNo="EN"  13912789ab="Rank"  PrdCode="7"  WEBHS3="Colour"  Udac=""><Keywords><Classification><Heading HdCode="HdName"  00866400=""></Heading></Classification><Raw>OPEN 7 DAYS A WEEK CALL US FOR SPECIALS</Raw><HrsOpr>7days</HrsOpr></Keywords><Text><Line Num="Val"  1="OPEN 7 DAYS A WEEK"></Line>
<Line Num="Val"  2="CALL US FOR SPECIALS"></Line>
</Text></HS></Products>
</ListEntry><ListEntry><DirProv>BC</DirProv><DirCode>086604</DirCode><HdCode>00866400</HdCode><Channel>1</Channel><Rank>7</Rank><NormRank>0</NormRank><Placement Child="false">DPlus</Placement><Products><HS DirPlus="1HS"  true="Lang"  AdNo="EN"  13908447ab="Rank"  PrdCode="7"  WEBHS3="Colour"  Udac=""><Keywords><Classification><Heading HdCode="HdName"  00866400=""></Heading></Classification><Raw>OPEN 7 DAYS A WEEK CALL US FOR SPECIALS</Raw><HrsOpr>7days</HrsOpr></Keywords><Text><Line Num="Val"  1="OPEN 7 DAYS A WEEK"></Line>
<Line Num="Val"  2="CALL US FOR SPECIALS"></Line>
</Text></HS></Products>
</ListEntry><ListEntry><DirProv>BC</DirProv><DirCode>086652</DirCode><HdCode>00866400</HdCode><Channel>1</Channel><Rank>7</Rank><NormRank>0</NormRank><Placement Child="false">DPlus</Placement><Products><HS DirPlus="1HS"  true="Lang"  AdNo="EN"  13890219ab="Rank"  PrdCode="7"  WEBHS3="Colour"  Udac=""><Keywords><Classification><Heading HdCode="HdName"  00866400=""></Heading></Classification><Raw>OPEN 7 DAYS A WEEK CALL US FOR SPECIALS</Raw><HrsOpr>7days</HrsOpr></Keywords><Text><Line Num="Val"  1="OPEN 7 DAYS A WEEK"></Line>
<Line Num="Val"  2="CALL US FOR SPECIALS"></Line>
</Text></HS></Products>
</ListEntry><ListEntry><DirProv>BC</DirProv><DirCode>086926</DirCode><HdCode>00866400</HdCode><Channel>1</Channel><Rank>7</Rank><NormRank>0</NormRank><Placement Child="false">DPlus</Placement><Products><HS DirPlus="1HS"  true="Lang"  AdNo="EN"  13980461ab="Rank"  PrdCode="7"  WEBHS3="Colour"  Udac=""><Keywords><Classification><Heading HdCode="HdName"  00866400=""></Heading></Classification><Raw>OPEN 7 DAYS A WEEK CALL US FOR SPECIALS</Raw><HrsOpr>7days</HrsOpr></Keywords><Text><Line Num="Val"  1="OPEN 7 DAYS A WEEK"></Line>
<Line Num="Val"  2="CALL US FOR SPECIALS"></Line>
</Text></HS></Products>
</ListEntry></Listing>
<Listing><ListingId>19</ListingId><DBID>18</DBID><BusName>&#39;Colleen All Dogs&#39; Doggie Daycare</BusName><BusNameFr>&#39;Colleen All Dogs&#39; Doggie Daycare</BusNameFr><Address>6058 144 Street</Address><City>Surrey</City><Prov>BC</Prov><PstCode>V3X1A3</PstCode><Lat>49.113197</Lat><Long>-122.823369</Long><Phone><Primary><Prefix>+1</Prefix><NPA>604</NPA><NXX>319</NXX><XNUM>3895</XNUM><DisplayNumber>604-319-3895</DisplayNumber></Primary><Other Type="Click2Call"><Prefix>+1</Prefix><NPA>604</NPA><NXX>319</NXX><XNUM>3895</XNUM><DisplayNumber>604-319-3895</DisplayNumber></Other></Phone>
<ListingKeys>D00007440120000535278</ListingKeys><ReportId>18</ReportId><Paid>Y</Paid><ListEntry><DirProv>BC</DirProv><DirCode>086446</DirCode><HdCode>00980600</HdCode><Channel>1</Channel><Rank>100</Rank><NormRank>6</NormRank><Placement Child="false">Other</Placement><Products><URL Type="Lang"  URL="EN"  PrdCode="LinkText"  P_LINK=""  Val="UrlImg"  http://www.colleenalldogs.com="u2/b/ad8/bad8592a30566ecbe27da92022963564.jpg"  Udac="Rank"  SUPEB="100"></URL><URL Type="Lang"  URL="FR"  PrdCode="LinkText"  P_LINK=""  Val="UrlImg"  http://www.colleenalldogs.com="u2/b/ad8/bad8592a30566ecbe27da92022963564.jpg"  Udac="Rank"  SUPEB="100"></URL></Products>
</ListEntry><ListEntry><DirProv>BC</DirProv><DirCode>086446</DirCode><HdCode>00980355</HdCode><Channel>1</Channel><Rank>194</Rank><NormRank>12</NormRank><Placement Child="false">DPlus</Placement><Products><D_PP PrdCode="EN"  D_PP="ProfileId"  Type="18042"  PPLUS="DirPath"  Udac="18042"  PPE="Rank"  Lang="50"><Keywords><OpenHrs>Monday 7:00 am - 6:30 pm</OpenHrs><OpenHrs>Tuesday 7:00 am - 6:30 pm</OpenHrs><OpenHrs>Wednesday 7:00 am - 6:30 pm</OpenHrs><OpenHrs>Thursday 7:00 am - 6:30 pm</OpenHrs><OpenHrs>Friday 7:00 am - 6:30 pm</OpenHrs><LangSpk>English</LangSpk><GetThr>King George Highway</GetThr><ProdServ>Administer Medications</ProdServ><ProdServ>Animal Care Experience</ProdServ><ProdServ>Dog Daycare</ProdServ><ProdServ>Dog Mind &amp; Body Stimulation</ProdServ><ProdServ>Dog Playhouse</ProdServ><ProdServ>Pet Portraits</ProdServ><ProdServ>Pet Shop</ProdServ></Keywords></D_PP>
<D_PP PrdCode="FR"  D_PP="ProfileId"  Type="18042"  PPLUS="DirPath"  Udac="18042"  ="Rank"  Lang="0"><Keywords><OpenHrs>Monday 7:00 am - 6:30 pm</OpenHrs><OpenHrs>Tuesday 7:00 am - 6:30 pm</OpenHrs><OpenHrs>Wednesday 7:00 am - 6:30 pm</OpenHrs><OpenHrs>Thursday 7:00 am - 6:30 pm</OpenHrs><OpenHrs>Friday 7:00 am - 6:30 pm</OpenHrs><LangSpk>English</LangSpk><GetThr>King George Highway</GetThr><ProdServ>Administer Medications</ProdServ><ProdServ>Animal Care Experience</ProdServ><ProdServ>Dog Daycare</ProdServ><ProdServ>Dog Mind &amp; Body Stimulation</ProdServ><ProdServ>Dog Playhouse</ProdServ><ProdServ>Pet Portraits</ProdServ><ProdServ>Pet Shop</ProdServ></Keywords></D_PP>
<URL Type="Lang"  URL="EN"  PrdCode="LinkText"  URL=""  Val="UrlImg"  http://www.colleenalldogs.com="u2/b/ad8/bad8592a30566ecbe27da92022963564.jpg"  Udac="Rank"  URL0="0"></URL><URL Type="Lang"  URL="FR"  PrdCode="LinkText"  URL=""  Val="UrlImg"  http://www.colleenalldogs.com="u2/b/ad8/bad8592a30566ecbe27da92022963564.jpg"  Udac="Rank"  URL0="0"></URL><URL Type="Lang"  URL="EN"  PrdCode="LinkText"  P_LINK=""  Val="UrlImg"  http://www.colleenalldogs.com="u2/b/ad8/bad8592a30566ecbe27da92022963564.jpg"  Udac="Rank"  SUPEB="100"></URL><URL Type="Lang"  URL="FR"  PrdCode="LinkText"  P_LINK=""  Val="UrlImg"  http://www.colleenalldogs.com="u2/b/ad8/bad8592a30566ecbe27da92022963564.jpg"  Udac="Rank"  SUPEB="100"></URL><Thumb Lang="THUMB"  EN="Udac"  Val="QCW"  14571890aa="Rank"  Type="44"  THUMB="DirPlus"  PrdCode="true"></Thumb><Thumb Lang="THUMB"  FR="Udac"  Val="QCW"  14571890aa="Rank"  Type="44"  THUMB="DirPlus"  PrdCode="true"></Thumb><DspAd Rank="DISPADT"  44="Lang"  DirPlus="EN"  true="Udac"  AdNo="QCW"  14571890aa="Type"  PrdCode="DspAd"><Keywords><Classification><Heading HdCode="HdName"  00980355=""></Heading></Classification><Raw>COLLEEN ALL DOGS Doggie Daycare 1/2 Acr  1/2 Acre of Secured Ine of Secured Indoodoor/Outr/Outdoodoor Spacr Spacee Puppy Social  Puppy Socialization, 100%ization, 100% Su Superpervisvisionion An  Any Agey Age/Size,/Size, By  By Appoint Appointmenment Onlyt Only Pet Firs  Pet First Aid, 17 t Aid, 17 YrsYrs Ani  Animal Knowledgemal Knowledge 604-604-319-38319-389595 6058 144th St Surrey, BC www.colleewww.colleewww.colleenallnallnalldogs.dogs.dogs.comcomcom</Raw></Keywords></DspAd></Products>
</ListEntry><ListEntry><DirProv>BC</DirProv><DirCode>086446</DirCode><HdCode>00740000</HdCode><Channel>1</Channel><Rank>100</Rank><NormRank>6</NormRank><Placement Child="false">Other</Placement><Products><URL Type="Lang"  URL="EN"  PrdCode="LinkText"  P_LINK=""  Val="UrlImg"  http://www.colleenalldogs.com="u2/b/ad8/bad8592a30566ecbe27da92022963564.jpg"  Udac="Rank"  SUPEB="100"></URL><URL Type="Lang"  URL="FR"  PrdCode="LinkText"  P_LINK=""  Val="UrlImg"  http://www.colleenalldogs.com="u2/b/ad8/bad8592a30566ecbe27da92022963564.jpg"  Udac="Rank"  SUPEB="100"></URL></Products>
</ListEntry></Listing>
</BusinessListings>

