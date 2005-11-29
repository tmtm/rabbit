begin
  require "gettext"
  module GetText
    alias _gettext gettext
    module_function :_gettext
    def gettext(msgid)
      if @@__textdomain[callersrc]
        _gettext(msgid)
      else
        msgid
      end
    end
  end
rescue LoadError
  module GetText

    module_function
    def bindtextdomain(*args)
    end
    
    def gettext(msgid)
      msgid
    end
  end

  module Locale
    module_function
    def get
      ["LC_ALL", "LC_MESSAGES", "LANG"].each do |env|
        ret = ENV[env]
        break if ret
      end
      ret = "C" unless ret
      ret
    end
  end
end

module Rabbit
  module GetText

    module_function
    def bindtextdomain(path=nil, locale=nil, charset=nil)
      charset ||= "UTF-8"
      ::GetText.bindtextdomain("rabbit", path, locale, charset)
    end
    
    def _(msgid)
      ::GetText.gettext(msgid)
    end

    def N_(msgid)
      msgid
    end

    def locale=(locale)
      ::GetText.locale = locale
    end
  end

  module Locale
    module_function
    def get
      ::Locale.get
    end
  end
end
