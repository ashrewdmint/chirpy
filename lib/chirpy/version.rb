module Chirpy
  module Version
    
    MAJOR = 0
    MINOR = 8
    TINY  = 0
    
    def self.to_s # :nodoc:
      [MAJOR, MINOR, TINY].join('.')
    end
    
  end
end