json.array!(@publishers) do |publisher|
  json.extract! publisher, :id
  json.url publisher_url(publisher, format: :json)
end
