class TradeCode < Sapi::Base
  validates :code, :presence => true, :uniqueness => { :scope => :type }

  def self.search(query)
    if query.present?
      where("UPPER(code) LIKE UPPER(:query)
            OR UPPER(name_en) LIKE UPPER(:query)
            OR UPPER(name_fr) LIKE UPPER(:query)
            OR UPPER(name_es) LIKE UPPER(:query)",
            :query => "%#{query}%")
    else
      scoped
    end
  end

  def name
    send("name_#{I18n.locale}")
  end
end
