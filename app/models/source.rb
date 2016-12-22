class Source < TradeCode
  validates :code, :length => { :is => 1 }
end
