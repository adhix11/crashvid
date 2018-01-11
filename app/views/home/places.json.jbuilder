json.array! @predictions do |prediction|
  json.description prediction["description"]
  json.place_id prediction["place_id"]
end
