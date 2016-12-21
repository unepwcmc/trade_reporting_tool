class Purpose < TradeCode
  validates :code, :length => { :is => 1 }
end
