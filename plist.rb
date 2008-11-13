require 'rubygems'
require_gem 'builder'

def plist( entries )
  buffer = ''
  write_plist( entries, buffer )
  buffer
end

def write_plist( entries, out = $stdout )
  xml = Builder::XmlMarkup.new( :target => out, :indent => 2 )

  xml.instruct!
  xml.declare! :DOCTYPE, :plist, :PUBLIC, '-//Apple Computer//DTD PLIST 1.0//EN', 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'

  xml.plist( 'version' => '1.0' ) {
    xml.dict {
      entries.each do |entry|
        xml.key( entry )
        process_plist_value( xml, eval( entry ) )
      end
    }
  }
end

def process_plist_value( xml, val )
  case val
    when Hash
      xml.dict {
        val.each do |k, v|
          xml.key( k )
          process_plist_value( xml, v )
        end
      }
    when String
      xml.string( val )
    when Integer
      xml.integer( val )
    when Array
      xml.array {
        val.each do |e|
          process_plist_value( xml, e )
        end
      }
    when Boolean
      if val == true
        xml.true
      else
        xml.false
      end
    end
end
