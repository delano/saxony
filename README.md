## Saxony - 0.2 ##

**Parse gigantic XML files with pleasure and without running out of memory.**

## Example ##
    
    sax = Saxony.new :SomeObject, 1000
    sax.parse 'path/2/huge.xml' do
      xml             # => The XML containing 1000 SomeObjects
      doc             # => Nokogiri object for 1000 SomeObjects
      total_count     # => Total number of SomeObjects processed
      elapsed_time    # => time processing current batch
      path            # => Current file being processed
    end
      
## Credits

* Delano Mandelbaum (http://solutious.com)


## Thanks 

* [Nokogiri](http://nokogiri.org/)

## License

See LICENSE.txt