class FileBinder
  class Listener
    CALLBACKS = %w(modified added removed)

    extend Forwardable
    def_delegators :@listen, :start, :stop, :listen?

    def initialize(pathname, opts = {}, &callback)
      @callback = callback || quiet_proc
      CALLBACKS.each do |callback|
        instance_variable_set("@#{callback}", quiet_proc)
      end

      @listen = ::Listen.to(pathname.to_s, opts) do |modified, added, removed|
        @callback.call(modified, added, removed)
        CALLBACKS.each do |name|
          callback = instance_variable_get("@#{name}")
          callback.call(eval(name)) unless eval(name).empty?
        end
      end

      @listen.start
    end

    CALLBACKS.each do |name|
      define_method "#{name}_on" do |callback|
        instance_variable_set("@#{name}", callback)
      end
    end

    private

    def quiet_proc
      Proc.new{ }
    end
  end
end
