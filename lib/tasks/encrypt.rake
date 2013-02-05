namespace :wiki_encryptor do
  desc "Encrypts wiki text"
  task :encrypt => :environment do
    WikiEncryptor.encrypt
  end
end
