json.array!(@choices) do |choice|
  json.extract! choice, :id
  json.url choice_url(choice, format: :json)
end
