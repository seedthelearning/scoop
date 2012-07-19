class Scoop
  require 'faraday'
  require 'json'

  BASE_API_URL = "http://localhost:3000/api/v1/"

  def connect
    Faraday.new url: BASE_API_URL
  end

  def get_seed(seed_id)
    response = connect.get "seeds/#{seed_id}.json"
    status = response.status
    response = JSON.parse(response.body)
    unless status == 200
      { status: status, error: response["error"]}
    else
      { status: status, id: response["id"].to_i, link: response["link"]}
    end
  end
end