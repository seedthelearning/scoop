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

  def parse_http_response(response)
    status = response.status
    response = JSON.parse(response.body)
    [status, response] 
  end

  def create_participant(user_id, link)
    participant = { user_id: user_id, link: link }
    response = connect.post "participants.json", participant
    status, response = parse_http_response(response)

    { status: status, participant: response }
  end

  def get_seed(seed_id)
    response = connect.get "seeds/#{seed_id}.json"
    status, response = parse_http_response(response)

    unless status == 200
      { status: status, error: response["error"]}
    else
      build_seed_with_status(response, status)
    end
  end

  def get_all_seeds
    response = connect.get "seeds.json"
    status, response = parse_http_response(response)

    seeds = response.collect do |seed|
      build_seed_without_status(seed)
    end
    { status: status, seeds: seeds }
  end

  def create_seed(user_id, amount_cents, link = nil)
    seed = {}.tap do |h|
      h[:user_id] = user_id
      h[:amount_cents] = amount_cents
      h[:link] = link if link
    end
    
    response = connect.post "seeds.json", seed
    status, response = parse_http_response(response)

    build_seed_with_status(response, status)
  end

  def reseed_seed(user_id, link, amount_cents)
    create_seed(user_id, amount_cents, link)
  end

  def get_tree(seed_id)
    response = connect.get "trees/#{seed_id}.json"
    status, response = parse_http_response(response)

    response.merge(:status => status)
  end

  private

  def build_seed_with_status(response, status)
    result = { status: status, id: response["id"].to_i, link: response["link"]}
    if response["donation"]
      result.merge!({ 
        user_id: response["user_id"].to_i,
        participants: response["child_count"],
        donation: get_donations_hash(response) })
    end
    result
  end

  def get_donations_hash(response)
    donation = response["donation"]
    {}.tap do |h|
      h[:amount_cents] = donation["amount_cents"]
      h[:payout_cents] = donation["payout_cents"]
      h[:total_donated] = response["total_donated"] if response["total_donated"]
    end
  end

  def build_seed_without_status(response)
    result = { id: response["id"].to_i, link: response["link"]}
    result.merge!({ donation: get_donations_hash(response) }) if response["donation"]
    result
  end
end