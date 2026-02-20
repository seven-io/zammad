require 'rails_helper'

RSpec.describe Channel::Driver::Sms::Seven do
  let(:api_key) { 'HeJyJSAvBWDn5RwNfhQGKZI6poCLk7pUXjpxctipYHWGsjoHtWNDI3d4De8gkoVe' }
  let(:from) { '+491000000000' }
  let(:to) { '+491716992343' }
  let(:text) { 'Test' }
  let(:api_url) { 'https://gateway.seven.io/api/sms' }

  let(:channel) do
    FactoryBot.create(:channel,
                      options: {
                        adapter: 'sms/seven',
                        from: from,
                        api_key: api_key
                      },
                      created_by_id: 1,
                      updated_by_id: 1)
  end

  it 'delivers successfully' do
    stub_request(:post, api_url)
      .with(
        body: { text: text, to: to, from: from }.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'X-Api-Key' => api_key,
          'SentWith' => 'zammad'
        }
      )
      .to_return(
        headers: { 'Content-Type' => 'application/json' },
        body: { success: '100' }.to_json
      )

    driver = channel.driver_instance.new
    expect(driver.deliver(channel.options, { recipient: to, message: text })).to be true
  end

  it 'raises on failure' do
    stub_request(:post, api_url)
      .to_return(
        headers: { 'Content-Type' => 'application/json' },
        body: { success: '305' }.to_json
      )

    driver = channel.driver_instance.new
    expect { driver.deliver(channel.options, { recipient: to, message: text }) }.to raise_exception(RuntimeError)
  end
end
