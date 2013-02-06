require_dependency "wiki_page"

module WikiPagePatch

  def self.included(base)
    unless WikiEncryptor::Configuration.key.nil?
      base.extend ClassMethods
    end
  end

  module ClassMethods

    def search(tokens, projects=nil, options={})
      if options[:titles_only]
        # Use default sql search
        super
      else
        # Load every encrypted wiki page and search tokens manually

        if projects.is_a?(Array) && projects.empty?
          # no results
          return [[], 0]
        end

        user = User.current
        tokens = [] << tokens unless tokens.is_a?(Array)
        projects = [] << projects unless projects.nil? || projects.is_a?(Array)

        scope = self.scoped
        project_conditions = []
        if searchable_options.has_key?(:permission)
          project_conditions << Project.allowed_to_condition(user, searchable_options[:permission] || :view_project)
        elsif respond_to?(:visible)
          scope = scope.visible(user)
        else
          ActiveSupport::Deprecation.warn "acts_as_searchable with implicit :permission option is deprecated. Add a visible scope to the #{self.name} model or use explicit :permission option."
          project_conditions << Project.allowed_to_condition(user, "view_#{self.name.underscore.pluralize}".to_sym)
        end
        project_conditions << "#{searchable_options[:project_key]} IN (#{projects.collect(&:id).join(',')})" unless projects.nil?
        project_conditions = project_conditions.empty? ? nil : project_conditions.join(' AND ')

        scope = scope.
            includes(searchable_options[:include]).
            where(project_conditions)

        results_count = 0
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
            results_count += 1
          end
        end

        scope = scope.order("#{searchable_options[:order_column]} " + (options[:before] ? 'DESC' : 'ASC'))
        scope_with_limit = scope.limit(options[:limit])
        if options[:offset]
          scope_with_limit = scope_with_limit.where("#{searchable_options[:date_column]} #{options[:before] ? '<' : '>'} ?", options[:offset])
        end
        result = scope_with_limit.where(id: results_ids).all

        [result, results_count]
      end
    end

  end

end

WikiPage.send(:include, WikiPagePatch)