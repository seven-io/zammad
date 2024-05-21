require 'rails_helper'

RSpec.describe Channel::Driver::Sms::Seven do
  it 'passes' do
    channel = create_channel

    stub_request(:get, url_to_mock)
        .to_return(body: '100')

    api = channel.driver_instance.new
    expect(api.send(channel.options, {to: to, text: text})).to be true
  end

  it 'fails' do
    channel = create_channel

    stub_request(:get, url_to_mock)
        .to_return(body: '305')

    api = channel.driver_instance.new
    expect { api.send(channel.options, {to: to, text: ''}) }.to raise_exception(RuntimeError)
  end

  private

  def create_channel
    FactoryBot.create(:channel,
                      options: {
                          adapter: 'sms/seven',
                          from: from,
                          api_key: api_key
                      },
                      created_by_id: 1,
                      updated_by_id: 1)
  end

  def url_to_mock
    'https://gateway.seven.io/api/sms?' + URI.encode_www_form({
                                                                  p: api_key,
                                                                  text: text,
                                                                  to: to,
                                                                  from: from
                                                              })
  end

  def text
    'Test'
  end

  def to
    '+491716992343'
  end

  def from
    '+491000000000'
  end

  def api_key
    'HeJyJSAvBWDn5RwNfhQGKZI6poCLk7pUXjpxctipYHWGsjoHtWNDI3d4De8gkoVe'
  end
end