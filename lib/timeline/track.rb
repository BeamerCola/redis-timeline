module Timeline::Track
  extend ActiveSupport::Concern

  module ClassMethods
    def track(name, options={})
      @name = name
      @callback = options.delete :on
      @callback ||= :create
      @actor = options.delete :actor
      @actor ||= :creator
      @object = options.delete :object
      @target = options.delete :target
      @followers = options.delete :followers
      @followers ||= :followers


      method_name = "track_#{@name}_after_#{@callback}".to_sym
      define_activity_method method_name, actor: @actor, object: @object, target: @target, followers: @followers, verb: name

      send "after_#{@callback}".to_sym, method_name, if: options.delete(:if)
    end

    private
      def define_activity_method(method_name, options={})
        define_method method_name do
          actor = send(options[:actor])
          object = !options[:object].nil? ? send(options[:object].to_sym) : self
          target = !options[:target].nil? ? send(options[:target].to_sym) : nil
          followers = actor.send(options[:followers].to_sym)
          add_activity activity(verb: options[:verb], actor: actor, object: object, target: target), followers
        end
      end
  end

  protected
    def activity(options={})
      {
        verb: options[:verb],
        actor: options_for(options[:actor]),
        object: options_for(options[:object]),
        target: options_for(options[:target])
      }
    end

    def add_activity(activity_item, followers)
      redis_add "global:activity", activity_item
      add_activity_to_user(activity_item, activity_item[:actor][:actor_id])
      add_activity_to_followers(activity_item, followers) if followers.any?
    end

    def add_activity_to_user(activity_item, user_id)
      redis_add "user:id:#{user_id}:activity", activity_item
    end

    def add_activity_to_followers(activity_item, followers)
      followers.each { |follower| add_activity_to_user(activity_item, follower.id) }
    end

    def redis_add(list, activity_item)
      Timeline.redis.lpush list, Timeline.encode(activity_item)
    end

    def options_for(target)
      if !target.nil?
        {
          id: target.id,
          class: target.class.to_s,
          display_name: target.to_s
        }
      else
        nil
      end
    end
end