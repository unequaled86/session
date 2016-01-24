require "http/server"
require "./cookies"
require "json"

class HTTP::Server::Context
  property! session
end

module Session
  class Session
    JSON.mapping({content: Hash(String, String)})

    def initialize
      @content = {} of String => String
    end

    def []=(key, value)
      @content[key] = value
    end
  end

  class Handler < HTTP::Handler
    def initialize(@session_key = "cr.session")
    end

    def call(context)
      context.session = load_session(context.request.cookies) || Session.new
      call_next(context)
      store_session(context.response, context.session)
    end

    private def load_session(cookies)
      if cookie = cookies[@session_key]?
        Session.from_json(cookie.value)
      end
    end

    private def store_session(response, session)
      response.set_cookie(@session_key, session.to_json)
    end
  end
end
