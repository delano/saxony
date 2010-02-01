## Saxony - 0.1 ##

**Parse gigantic XML files with pleasure and a without running out of memory.**

## Example ##
    
    sax = Saxony.new :SomeObject, 1000
    sax.parse 'path/2/huge.xml' do
      total_count     # => Total number of SomeObjects processed
      doc             # => Nokogiri object for 1000 SomeObjects
      elapsed_time    # => time processing current batch
      path            # => Current file being processed
      xml             # => The XML containing 1000 SomeObjects
    end
      
## Credits

* Delano Mandelbaum (http://solutious.com)


## Thanks 

* [Nokogiri](http://nokogiri.org/)

## License

See LICENSE.txt