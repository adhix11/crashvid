json.extract! event, :id, :latitude, :longitude, :date_of_occurence, :created_at, :updated_at
json.url event_url(event, format: :json)