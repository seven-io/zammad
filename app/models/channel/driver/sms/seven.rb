class Channel::Driver::Sms::Seven < Channel::Driver::Sms::Base
  NAME = 'sms/seven'.freeze

  def deliver(options, attr, _notification = false)
    Rails.logger.info "Sending SMS to recipient #{attr[:recipient]}"

    return true if Setting.get('import_mode')

    Rails.logger.info "Backend sending seven SMS to #{attr[:recipient]}"
    begin
      url = 'https://gateway.seven.io/api/sms?' + URI.encode_www_form({
                                                                          p: options[:api_key],
                                                                          text: attr[:message],
                                                                          to: attr[:recipient],
                                                                          from: options[:from],
                                                                          sendWith: 'zammad',
                                                                      })

      if Setting.get('developer_mode') != true
        response = Faraday.get(url).body
        raise response if '100' != response
      end

      true
    rescue => e
      Rails.logger.debug "seven error: #{e.inspect}"
      raise e
    end
  end

  def self.definition
    {
        name: 'seven',
        adapter: 'sms/seven',
        notification: [
            {name: 'options::api_key', display: 'API Key', tag: 'input', type: 'text', limit: 64, null: false, placeholder: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'},
            {name: 'options::from', display: 'From', tag: 'input', type: 'text', limit: 16, null: true, placeholder: '00491710000000'},
        ]
    }
  end
end