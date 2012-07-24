class Scoop
  attr_accessor :default_api_url
  require 'faraday'
  require 'json'

  def connect
    Faraday.new url: @default_api_url
  end

  def initialize(url)
    @default_api_url = url
  end

  def create_participant(user_id, link)
    participant = { user_id: user_id, link: link }
    response = connect.post "participants.json", participant
    status = response.status
    response = JSON.parse(response.body)

    result = { status: status, participant: response }
  end

  def get_seed(seed_id)
    response = connect.get "seeds/#{seed_id}.json"
    status = response.status
    response = JSON.parse(response.body)

    unless status == 200
      { status: status, error: response["error"]}
    else
      build_seed_with_status(response, status)
    end
  end

  def get_all_seeds
    response = connect.get "seeds.json"
    status = response.status
    response = JSON.parse(response.body)
    seeds = response.collect do |seed|
      build_seed_without_status(seed)
    end
    { status: status,
      seeds: seeds }
  end

  def create_seed(user_id, amount_cents)
    seed = { user_id: user_id, amount_cents: amount_cents }
    response = connect.post "seeds.json", seed
    status = response.status
    response = JSON.parse(response.body)
    build_seed_with_status(response, status)
  end

  def reseed_seed(user_id, link, amount_cents)
    reseed = { user_id: user_id, link: link, amount_cents: amount_cents }
    response = connect.post "seeds.json", reseed
    status = response.status
    response = JSON.parse(response.body)
    build_seed_with_status(response, status)
  end

  def get_tree(seed_id)
    response = connect.get "trees/#{seed_id}.json"
    status = response.status
    response = JSON.parse(response.body)
    response[:status] = status
    response
  end

  private

  def build_seed_with_status(response, status)
    if response["donation"]
      donation = response["donation"]
      result = { status: status,
        id: response["id"].to_i,
        user_id: response["user_id"].to_i,
        link: response["link"],
        donation: { amount_cents: donation["amount_cents"],
                    payout_cents: donation["payout_cents"] } }
    else
      result = { status: status, id: response["id"].to_i, link: response["link"]}
    end
    result
  end

  def build_seed_without_status(response)
    if response["donation"]
      donation = response["donation"]
      result = {
        id: response["id"].to_i,
        link: response["link"],
        donation: { amount_cents: donation["amount_cents"],
                    payout_cents: donation["payout_cents"] } }
    else
      result = { id: response["id"].to_i, link: response["link"]}
    end
    result
  end
end