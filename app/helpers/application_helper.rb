module ApplicationHelper

  def nice_time(time)
    return '?' if time.nil?
    nice = ""
    nice = "#{time.floor / 60}:" if time > 60
    mod = time % 60
    "#{nice}#{mod < 10 ? '0' : ''}#{number_with_precision(mod, :precision => 3)}"
  end

  def is_current?(obj, at_obj)
    "bg-success" if obj == at_obj
  end

  def bootstrap_alert(name)
    case name
      when :notice
        "alert-success"
      when :alert
        "alert-danger"
      else
        nil
    end
  end

  def breadcrumb(obj, leaf = false)
    case obj
      when Session
        breadcrumb(obj.race) + content_tag('li', breadcrumb_link(obj, leaf), :class => (leaf ? 'active' : ''))
      when Race
        breadcrumb(obj.season) + content_tag('li', breadcrumb_link(obj, leaf))
      when Season
        breadcrumb(obj.league) + content_tag('li', breadcrumb_link(obj, leaf))
      when League
        breadcrumb(obj.super_league) + content_tag('li', breadcrumb_link(obj, leaf))
      when SuperLeague
        content_tag('li', obj.name)
      else
        nil
    end
  end

  def breadcrumb_link(obj, leaf)
    case obj
      when Session
        obj.name
      when Race
        leaf ? obj.name : link_to(obj.name, race_path(obj))
      when Season
        leaf ? obj.name : link_to(obj.name, season_path(obj))
      when League
        leaf ? obj.name : link_to(obj.name, league_path(obj))
      else
        nil
    end
  end

  def cancel_link(obj, admin = true)
    if obj.new_record?
      path = :back
    else
      path = case obj
        when Screenshot
          admin ? edit_say_what_session_path(obj.session) : session_path(obj.session)
        when Session
          say_what_sessions_path
        when Race
          say_what_races_path
        when Season
          say_what_seasons_path
        when League
          say_what_leagues_path
        when SuperLeague
          say_what_super_leagues_path
        when Track
          say_what_tracks_path
        when Driver
          admin ? say_what_drivers_path : edit_user_path(obj.user)
        when Lap
          say_what_laps_path
        else
          nil
      end
    end

    link_to('Cancel', path)
  end

  def admin_path
    params[:controller] =~ /say_what/
  end

  def nice_name(obj, as_id = false)
    name = obj.is_a?(String) ? obj : obj.try(:name)
    name = name.gsub(/ /, '-').downcase if as_id
    name
  end

  def nice_field(obj, field)
    unless obj.send(field).nil?
      case field
        when 'speed'
          (obj.send(field) * 3.6).round(3)
        when 'fuel'
          delta = obj.send("#{field}_delta").round(3)
          value = "#{obj.send(field).round(3)}"
          unless delta == 0
            value += " (#{delta < 0 ? '' : '+'}#{delta})"
          end
          value.html_safe
        when 'position'
          delta = obj.send("#{field}_delta")
          value = "#{obj.send(field)}"
          unless delta == 0
            value += "(#{delta < 0 ? '' : '+'}#{delta})"
          end
          value.html_safe
        else
          nil
      end
    end
  end

  def display_help(msg)
    content_tag('span', '', :class => 'glyphicon glyphicon-question-sign help-popover', :data => { :container => 'body', :toggle => 'popover', :placement => 'right', :content => msg })
  end

end
