Audit = Audited::Audit

# пока не тащим миграцию из audited:upgrade, т.к. таблица там большая
class Audit
  attr_accessor :request_uuid
end
