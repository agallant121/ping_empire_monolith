json.extract! response, :id, :website_id, :status_code, :response_time, :checked_at, :error, :created_at, :updated_at
json.url response_url(response, format: :json)
