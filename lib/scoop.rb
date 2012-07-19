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
      build_seed_json(response)
    end
  end

  def get_all_seeds
    response = connect.get "seeds.json"
    status = response.status
    response = JSON.parse(response.body)
    seeds = response.collect do |seed|
      build_seed_json(seed)
    end
    foo = { status: status,
      seeds: seeds }
  end

  private

  def build_seed_json(response)
    if response["donation"]
      donation = response["donation"]
      result = { status: 200,
        id: response["id"].to_i,
        link: response["link"],
        donation: { amount_cents: donation["amount_cents"],
                    payout_cents: donation["payout_cents"] } }
    else
      result = { status: 200, id: response["id"].to_i, link: response["link"]}
    end
    result
  end
end