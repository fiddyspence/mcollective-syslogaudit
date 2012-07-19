module MCollective
  module RPC
    # An audit plugin that logs to syslog
    class Syslogaudit<Audit

      require 'pp'
      require 'syslog'

      def audit_request(request, connection)

        configfacility = Config.instance.pluginconf["syslogaudit.facility"] || "authpriv"
        configlevel = Config.instance.pluginconf["syslogaudit.level"] || "info"
        facility = syslog_facility(configfacility)
        level = configlevel.to_sym

        Syslog.open(File.basename($0), 3, facility)

        now = Time.now
        now_tz = tz = now.utc? ? "Z" : now.strftime("%z")
        now_iso8601 = "%s.%06d%s" % [now.strftime("%Y-%m-%dT%H:%M:%S"), now.tv_usec, now_tz]

        Syslog.send(level,"#{now_iso8601}: reqid=#{request.uniqid}: reqtime=#{request.time} caller=#{request.caller}@#{request.sender} agent=#{request.agent} action=#{request.action} data=#{request.data.pretty_print_inspect}")
        Syslog.close

      end

      def syslog_facility(facility)
        begin
          Syslog.const_get("LOG_#{facility.upcase}")
        rescue NameError => e
          STDERR.puts "Invalid syslog facility #{facility} supplied, reverting to USER"
          Syslog::LOG_AUTHPRIV
        end
      end

    end
  end
end
