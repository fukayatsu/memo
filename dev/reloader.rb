require "faye/websocket"

class Reloader
  def call(env)
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)
      ws.rack_response # Return async Rack response
    else
      # Normal HTTP request
      [200, { 'Content-Type' => 'text/plain' }, ['Hello']]
    end
  end
end
