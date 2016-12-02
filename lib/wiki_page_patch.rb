require_dependency "wiki_page"

module WikiPagePatch

  def self.included(base)
    unless WikiEncryptor::Configuration.key.nil?
      base.extend ClassMethods
    end
    base.class_eval do
      # Same as typing in the class.
      unloadable # Send unloadable so it will not be unloaded in development.
      safe_attributes 'not_index'
    end
  end

  module ClassMethods

    def not_index
      true
    end

    #   WikiPage.search_result_ranks_and_ids("foo")
    #   # => [[1419595329, 69], [1419595622, 123]]
    def search_result_ranks_and_ids(tokens, user=User.current, projects=nil, options={})
      if options[:titles_only]
        # Use default sql search
        super
      else
        # Load every encrypted wiki page and search tokens manually

        if projects.is_a?(Array) && projects.empty?
          # no results
          return none
        end

        tokens = [] << tokens unless tokens.is_a?(Array)
        projects = [] << projects if projects.is_a?(Project)

        scope = (searchable_options[:scope] || self)
        if scope.is_a? Proc
          scope = scope.call(options)
        end
        permission = searchable_options[:permission] || :view_project
        scope = scope.where(Project.allowed_to_condition(user, permission))

        if projects
          scope = scope.where("#{searchable_options[:project_key]} IN (?)", projects.map(&:id))
        end

        results_ids = []
        need_matches = options[:all_words] ? tokens.length : 1

        scope.find_each do |wiki_page|
          matches_count = 0
          page_title = wiki_page.title.mb_chars.downcase
          page_text = wiki_page.content.text ? wiki_page.content.text.mb_chars.downcase : ""
          tokens.each do |token|
            token = token.mb_chars.downcase
            matches_count += 1 if page_title.include?(token) || page_text.include?(token)
          end
          if matches_count >= need_matches
            results_ids << wiki_page.id
          end
        end

        scope.
          where(id: results_ids).
          reorder(searchable_options[:date_column] => :desc, :id => :desc).
          limit(options[:limit]).
          distinct.
          pluck(searchable_options[:date_column], :id).
          # converts timestamps to integers for faster sort
          map {|timestamp, id| [timestamp.to_i, id]}
      end
    end

  end

end

WikiPage.send(:include, WikiPagePatch)
