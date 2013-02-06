# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

# Load test configuration with encryption key and algorithm
Redmine::Configuration.load(
    :file => File.expand_path("../with_encryption.yml", __FILE__),
    :env => 'test'
)
# Patches depends on configuration, so just reload them.
load File.expand_path(File.dirname(__FILE__) + '/../lib/wiki_content_patch.rb')
load File.expand_path(File.dirname(__FILE__) + '/../lib/wiki_content_version_patch.rb')
load File.expand_path(File.dirname(__FILE__) + '/../lib/wiki_page_patch.rb')