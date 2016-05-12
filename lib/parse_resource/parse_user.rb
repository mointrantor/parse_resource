require 'parse_resource/parse_user_validator'

class ParseUser < ParseResource::Base
  fields :username, :password

  def self.authenticate(username, password)
    base_uri   = "#{full_path}/login"
    resource = RestClient::Resource.new(base_uri, :headers => request_header)
    
    begin
      resp = resource.get(:params => {:username => username, :password => password})
      user = model_name.to_s.constantize.new(JSON.parse(resp), false)
            
      user 
    rescue => e
      puts e.inspect
      false
    end
    
  end
  
  def self.authenticate_with_facebook(user_id, access_token, expires)
    base_uri   = "#{full_path}/users"
    resource = RestClient::Resource.new(base_uri, :headers => request_header)

    begin
      resp = resource.post(
          { "authData" =>
                            { "facebook" =>
                                  {
                                      "id" => user_id,
                                      "access_token" => access_token,
                                      "expiration_date" => Time.now + expires.to_i
                                  }
                            }
                      }.to_json,
                     :content_type => 'application/json', :accept => :json)
      user = model_name.to_s.constantize.new(JSON.parse(resp), false)
      user
    rescue
      false
    end
  end
  
  def self.reset_password(email)
      base_uri   = "#{full_path}/requestPasswordReset"
      resource = RestClient::Resource.new(base_uri, :headers => request_header)
      
      begin
        resp = resource.post({:email => email}.to_json, :content_type => 'application/json')
        true
      rescue
        false
      end
  end
end
