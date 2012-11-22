class JS
  include ActionView::Helpers::JavaScriptHelper

  def self.escape( text )
    @instance ||= self.new
    return @instance.escape_javascript( text )
  end
end
