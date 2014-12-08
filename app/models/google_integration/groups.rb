module GoogleIntegration
  class Groups

    def self.all
      raw_data.map do |group_name, group_data|
        Group.new(
          group_name,
          group_data.members,
          group_data.aliases
        )
      end
    end

    private

    def self.raw_data
      Storage.data.google_groups
    end
  end

  class Group
    attr_reader :name, :members, :aliases
    def initialize(name, members, aliases)
      @name = name
      @members = members
      @aliases = aliases
    end
  end
end