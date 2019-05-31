if Rails.env.development? || Rails.env.staging?
  GO_CARDLESS_CLIENT = GoCardlessPro::Client.new(
    # We recommend storing your access token in an
    # environment variable for security, but you could
    # include it as a string directly in your code
    access_token: ENV['gocardless_access_token'],
    # Remove the following line when you're ready to go live
    environment: :sandbox
  )
else
  GO_CARDLESS_CLIENT = GoCardlessPro::Client.new(
    # We recommend storing your access token in an
    # environment variable for security, but you could
    # include it as a string directly in your code
    access_token: ENV['gocardless_access_token']
    # Remove the following line when you're ready to go live
    # environment: :sandbox
  )
end
