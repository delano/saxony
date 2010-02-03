## Saxony - 0.3 ##

**Parse gigantic XML files with pleasure and without running out of memory.**

## Example ##
    
    sax = Saxony.new :SomeObject, 1000
    sax.parse 'path/2/huge.xml' do
      xml             # => The XML containing 1000 SomeObjects
      doc             # => Nokogiri object for 1000 SomeObjects
      total_count     # => Total number of SomeObjects processed
      elapsed_time    # => time processing current batch
      path            # => Current file being processed
      fh              # => Output file handle
    end
    
    # Process multiple files in parallel using Kernel.proc.
    # By default
    Saxony.fork ['path/2/huge.xml', 'path/2/huger.xml'] do
      # Inside the block, everything is the  
      # same as calling sax.parse above. 
      doc.xpath('//Listing').each do |l
        type = listing.xpath("Type").first.text
        fh.puts listing if type == 'some_criteria'
      end
    end
    
    
## Credits

* Delano Mandelbaum (http://solutious.com)


## Thanks 

* [Nokogiri](http://nokogiri.org/)

## License

See LICENSE.txt