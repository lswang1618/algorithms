json.array!(@responses) do |response|
  json.extract! response, :id
  json.url response_url(response, format: :json)
end
