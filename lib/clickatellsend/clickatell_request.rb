module Clickatellsend
  # Request class
  class Request
    def initialize
      @url = Clickatellsend.config[:url]
      @user = Clickatellsend.config[:user]
      @password = Clickatellsend.config[:password]
      @api_id = Clickatellsend.config[:api_id]
    end

    # :to, :text, :deliv_time
    # response(RestClient.get "#{@url}http/sendmsg",
    #                         {:params => options(params)})
    def send_msg(params)
      params = options(params)
      RestClient::Request.execute(
        method: :post, url: "#{@url}/messages",
        payload: { to: params[:to], content: params[:text] },
        headers: {
          content_type: 'application/json',
          accept: 'application/json',
          authorization: params[:api_id]
        }
      )
    end

    # https://www.clickatell.com/developers/api-documentation/http-api-get-account-balance/
    # response(RestClient.get "#{@url}http/getbalance",
    #                         {:params => options({})})
    def get_balance
      RestClient::Request.execute(
        method: :get, url: "#{@url}/public-client/balance",
        headers: {
          accept: 'application/json',
          authorization: @api_id
        }
      )
    end

    # :apimsgid
    # response(RestClient.get "#{@url}http/getmsgcharge",
    #                         {:params => options(params)})
    def get_msg_charge(params)
      params = options(params)
      RestClient::Request.execute(
        method: :get, url: "#{@url}/",
        payload: { to: params[], content: params[] },
        headers: { accept: 'application/json', authorization: params[:api_id] }
      )
    end

    # :msisdn
    # response(RestClient.get "#{@url}utils/routecoverage",
    #                         {:params => options(params)})
    def route_coverage(params)
      params = options(params)
      # byebug
      response(RestClient.get "#{@url}utils/routecoverage", {:params => options(params)})
    end

    # :apimsgid
    # response(RestClient.get "#{@url}http/querymsg",
    #                         {:params => options(params)})
    def get_msg_status(params)
      params = options(params)
      RestClient::Request.execute(
        method: :get,
        url: "#{@url}/public-client/message/status?messageId=#{params[:msg_id]}",
        headers: { accept: 'application/json', authorization: @api_id }
      )
    end

    # :apimsgid
    # response(RestClient.get "#{@url}http/delmsg",
    #                         {:params => options(params)})
    def stop_msg(params)
      response(RestClient.get "#{@url}http/delmsg", {:params => options(params)})
    end

    def auth
      response(RestClient.get "#{@url}http/auth", {:params => options({})})
    end

    # :session_id
    def prevent_expiring(params)
      response(RestClient.get "#{@url}http/ping", {:params => params})
    end

    private

    def options(params)
      if params[:session_id]
        params.merge({:api_id => @api_id})
      else
        params.merge({:user => @user, :password => @password, :api_id => @api_id})
      end
    end

    def response(request)
      if request.code == 200
        response = request.split("\n").map{|l| l.scan(/(\w+):\s($|[\w, \d.]+)(?:\s|$)/)}.map &:to_h
        response[0] if response.size == 1
      else
        {:ERR => "Could not connect to the API, double check your settings and internet connection"}
      end
    end
  end
end
