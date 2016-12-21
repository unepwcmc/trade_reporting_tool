class Unit < TradeCode
  validates :code, :length => { :is => 3 }
end
