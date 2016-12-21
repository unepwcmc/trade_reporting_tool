class Term < TradeCode
  validates :code, :length => { :is => 3 }
end
