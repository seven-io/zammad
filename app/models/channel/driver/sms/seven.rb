class Channel::Driver::Sms::Seven < Channel::Driver::Sms::Base
  NAME = 'sms/seven'.freeze

  def fetchable?(_channel)
    false
  end

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

      if Setting.get('developer_mode') != false
        response = Faraday.get(url).body
        Rails.logger.debug "seven response: #{response}"
        raise response if '100' != response
      end

      true
    rescue => e
      Rails.logger.debug "seven error: #{e.inspect}"
      raise e
    end
  end

  def process(_options, attr, channel)
    from = attr['data']['sender']

    Rails.logger.info "Receiving SMS from recipient #{from}"

    if from.sub('+', '').scan(/^\d+$/).empty?
      Rails.logger.info "Skipping inbound SMS because the sender is not a valid phone number: #{from}"
      return [:json, {}]
    end

    msg_id = attr['data']['id']
    # prevent already created articles
    if Ticket::Article.exists?(message_id: msg_id)
      Rails.logger.info "Skipping inbound SMS because a ticket with this ID already exists: #{msg_id}"
      return [:json, {}]
    end

    # find sender
    user = user_by_mobile(from)
    UserInfo.current_user_id = user.id

    process_ticket(attr, channel, user)

    [:json, {}]
  end

  def create_ticket(attr, channel, user)
    title = cut_title(attr['data']['text'])
    ticket = Ticket.new(
      group_id: channel.group_id,
      title: title,
      state_id: Ticket::State.find_by(default_create: true).id,
      priority_id: Ticket::Priority.find_by(default_create: true).id,
      customer_id: user.id,
      preferences: {
        channel_id: channel.id,
        sms: {
          originator: attr['data']['sender'],
          recipient: attr['data']['system'],
        }
      }
    )
    ticket.save!
    ticket
  end

  def create_article(attr, channel, ticket)
    Ticket::Article.create!(
      ticket_id: ticket.id,
      type: article_type_sms,
      sender: Ticket::Article::Sender.find_by(name: 'Customer'),
      body: attr['data']['text'],
      from: attr['data']['sender'],
      to: attr['data']['system'],
      message_id: attr['data']['id'],
      content_type: 'text/plain',
      preferences: {
        channel_id: channel.id,
        sms: {
          From: attr['data']['sender'],
          To: attr['data']['system'],
        },
      }
    )
  end

  def self.definition
    {
      name: 'seven',
      adapter: 'sms/seven',
      account: [
        { name: 'options::webhook_token', display: __('Webhook Token'), tag: 'input', type: 'text', limit: 200, null: false, default: Digest::MD5.hexdigest(SecureRandom.uuid), disabled: true, readonly: true },
        { name: 'options::api_key', display: 'API Key', tag: 'input', type: 'text', limit: 64, null: false, placeholder: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' },
        { name: 'options::from', display: 'From', tag: 'input', type: 'text', limit: 16, null: true, placeholder: '00491710000000' },
        { name: 'group_id', display: __('Destination Group'), tag: 'tree_select', null: false, relation: 'Group', nulloption: true, filter: { active: true } },
      ],
      notification: [
        { name: 'options::api_key', display: 'API Key', tag: 'input', type: 'text', limit: 64, null: false, placeholder: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' },
        { name: 'options::from', display: 'From', tag: 'input', type: 'text', limit: 16, null: true, placeholder: '00491710000000' },
      ]
    }
  end
end
