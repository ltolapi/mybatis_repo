maintainer       "Scholastic"
maintainer_email "h-ops@scholastic.com"
license          "All rights reserved"
description      "Installs/Configures mybatis"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.5.1"
#%w{ application java }.each do |cb|
#  depends cb
#end
depends "java"
depends "maven"
