## Saxony - 0.1 ##

**Parse gigantic XML files with pleasure and ease.**

## Example ##
    
    sax = Saxony.new :SomeObject, 1000
    sax.parse 'path/2/huge.xml' do
      total_count     # => Total number of SomeObjects processed
      doc             # => Nokogiri object for 1000 SomeObject
      elapsed_time    # => time processing current batch
    end
      
## Credits

* Delano Mandelbaum (http://solutious.com)


## Thanks 


## License

See LICENSE.txt