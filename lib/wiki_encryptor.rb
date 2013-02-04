module WikiEncryptor

  module Configuration

    def self.key
      configuration = Redmine::Configuration['wiki_encryptor']
      configuration && configuration['key'] ? configuration['key'] : nil
    end

    def self.algorithm
      configuration = Redmine::Configuration['wiki_encryptor']
      configuration && configuration['algorithm'] ? configuration['algorithm'] : 'aes-256-cbc'
    end

  end

end