json.array!(@researchers) do |researcher|
  json.extract! researcher, :id
  json.url researcher_url(researcher, format: :json)
end
