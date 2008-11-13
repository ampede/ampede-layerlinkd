OBJC_SOURCES = {
  'AboutView.m' => %w{
    LayerLinkPlugin.h
  },
  'LayerLinkPlugin.m' => %w{
    AboutView.h
  }
}

#######################################################################################

# create manual require dependencies
OBJC_SOURCES.each { |k,v| file k => v }

# create implied source header dependencies
OBJC_SOURCES.keys.each { |k| file k => k.gsub(/m$/, 'h') }
