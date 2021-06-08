Audit = Audited::Adapters::ActiveRecord::Audit
#TODO: potential vulnarability
Audit.attr_accessible :username, :user, :version, :auditable


# пока не тащим миграцию из audited:upgrade, т.к. таблица там большая
class Audit
  attr_accessor :request_uuid
end
