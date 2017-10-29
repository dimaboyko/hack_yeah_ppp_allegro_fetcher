# extend ::Concerns::Performable
module Concerns
  module Performable
    def perform(*args)
      new(*args).send(:perform)
    end
  end
end
