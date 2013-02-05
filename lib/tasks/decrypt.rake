namespace :wiki_encryptor do
  desc "Decrypts encrypted wiki text"
  task :decrypt => :environment do
    WikiEncryptor.decrypt
  end
end
