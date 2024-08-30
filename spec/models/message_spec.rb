require "spec_helper"

RSpec.describe(Message) do
  it "decrypts an existing message" do
    message_id = create(
      :message,
      body: nil,
      subject: nil,
      encrypted_body: "TxUvWv92rFdZrC2+i5gkDK7MXmbgdglwOA==\n",
      encrypted_body_iv: "ENPphSDoOVNz9T20\n",
      encrypted_subject: "vqUeCFfXh3rp7UIE2Ua0sBjt3OplcA==\n",
      encrypted_subject_iv: "tSTKL6S0yB1ejjPQ\n",
    ).id
    message = Message.find(message_id)

    expect(message.subject).to eq("Hello!")
    expect(message.body).to eq("It works!")
  end

  it "encrypts and decrypts a new message" do
    message_id = create(:message, subject: "Hello!", body: "It works!").id
    message = Message.find(message_id)

    expect(message.subject).to eq("Hello!")
    expect(message.body).to eq("It works!")
  end
end
