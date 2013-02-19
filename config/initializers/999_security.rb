# General security improvements
#
# Disable XML/JSON functions that are not needed,
# see https://groups.google.com/forum/?fromgroups=#!topic/rubyonrails-security/61bkgvnSGTQ

ActiveSupport::XmlMini::PARSING.delete("symbol")
ActiveSupport::XmlMini::PARSING.delete("yaml") 

ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML) 