# The TCP Server
module IrcCat
  class TcpServer
    def self.run(bot, config)
      new(bot, config).run
    end

    def initialize(bot, config)
      @bot, @config = bot, config
    end

    def run
      Thread.new do
        puts "Starting TCP (#{ip}:#{port})"
        socket = TCPServer.new(ip, port)

        loop do
          Thread.start(socket.accept) do |s|
            channels = @channels
            str = s.recv(@config['size'])
            if str.match /^(#[^\W]+)\s(.+)/m
              str = $2
              channels = $1.split(',').collect {|channel| [channel,]}
            end
            while (str.length > 0) do
              sstr = str.split(/\n/)
              sstr.each do |l|
                @bot.announce("#{l}", channels) unless l.length <= 1
              end
              str = s.recv(@config['size'])
            end
            s.close
          end
        end
      end
    end

    def ip
      @config["ip"] || '127.0.0.1'
    end

    def port
      @config["port"] || '8080'
    end
  end
end
