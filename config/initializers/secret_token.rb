# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
#
# old, probably compromised, open on GitHub
#Snpr::Application.config.secret_token = '33db2b9c82b8eb511e884437941fbc7e6af8483a79333d4170e8c57a41b7ca4556ed1f7b92700893cddd4465fc4de79a37bf44615ebc891dd83f2612ec531e05'
begin 
    token_file = Rails.root.to_s + "/secret_token"
    to_load = open(token_file).read
    Snpr::Application.configure do
        config.secret_token = to_load
    end
rescue LoadError, Errno::ENOENT => e
    raise "Secret token couldn't be loaded! Error: #{e}"
end
