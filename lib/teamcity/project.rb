module Teamcity
  class Project < Base
    list_url :projects
    has_collection :build_types, ::Teamcity::BuildType
  end
end