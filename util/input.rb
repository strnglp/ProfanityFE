module Input
  # Key chord definitions - these change across platforms and keyboard layouts
  # TODO: a more robust layout-aware system
  KEY_NAME = {
    'ctrl+a'        => 1,
    'ctrl+b'        => 2,
    #  'ctrl+c'    => 3,
    'ctrl+d'        => 4,
    'ctrl+e'        => 5,
    'ctrl+f'        => 6,
    'ctrl+g'        => 7,
    'ctrl+h'        => 8,
    'win_backspace' => 8,
    'ctrl+i'        => 9,
    'tab'           => 9,
    'ctrl+j'        => 10,
    'enter'         => 10,
    'ctrl+k'        => 11,
    'ctrl+l'        => 12,
    'return'        => 13,
    'ctrl+m'        => 13,
    'ctrl+n'        => 14,
    'ctrl+o'        => 15,
    'ctrl+p'        => 16,
    #  'ctrl+q'    => 17,
    'ctrl+r'        => 18,
    #  'ctrl+s'    => 19,
    'ctrl+t'        => 20,
    'ctrl+u'        => 21,
    'ctrl+v'        => 22,
    'ctrl+w'        => 23,
    'ctrl+x'        => 24,
    'ctrl+y'        => 25,
    'ctrl+z'        => 26,
    'alt'           => 27,
    'escape'        => 27,
    'ctrl+?'        => 127,
    'down'          => 258,
    'up'            => 259,
    'left'          => 260,
    'right'         => 261,
    'home'          => 262,
    'backspace'     => 263,
    'f1'            => 265,
    'ctrl_backspace'=> 265,
    'f2'            => 266,
    'f3'            => 267,
    'f4'            => 268,
    'f5'            => 269,
    'f6'            => 270,
    'f7'            => 271,
    'f8'            => 272,
    'f9'            => 273,
    'f10'           => 274,
    'f11'           => 275,
    'f12'           => 276,
    'delete'        => 330,
    'insert'        => 331,
    'page_down'     => 338,
    'page_up'       => 339,
    'end'           => 360,
    'resize'        => 410,
    'num_7'         => 449,
    'num_8'         => 450,
    'num_9'         => 451,
    'num_4'         => 452,
    'num_5'         => 453,
    'num_6'         => 454,
    'num_1'         => 455,
    'num_2'         => 456,
    'num_3'         => 457,
    'num_enter'     => 459,
    'ctrl+delete'   => 513,
    # 'alt+page_down' => 542,
    # 'alt+page_up'   => 547,
    'alt+up'        => 573,
    'alt+down'      => 532,
    'alt+left'      => 552,
    'alt+right'     => 567,
    'ctrl+up'       => 568,
    'ctrl+down'     => 527,
    'ctrl+left'     => 547,
    'ctrl+right'    => 562,
    'shift+up'      => 337,
    'shift+down'    => 336,
  }

  # TODO make this more dynamic, not all keylayouts will be the same
  if RbConfig::CONFIG['host_os'] !~ /darwin/
    KEY_NAME['ctrl+up'] = 571
    KEY_NAME['ctrl+down'] = 530
    KEY_NAME['ctrl+left'] = 550
    KEY_NAME['ctrl+right'] = 565
    KEY_NAME['ctrl_backspace'] = 8
  end

  @key_binding = Hash.new
  @key_combo = nil
  @do_macro = nil

  class << self
    attr_reader :key_binding

    def set_macro_handler(macro_handler)
      @do_macro = macro_handler
    end

    # Assign actions(procs) to keys from XML config
    def load_bindings(xml, actions)
      if (key = xml.attributes['id'])
        if key =~ /^[0-9]+$/
          key = key.to_i
        elsif key.is_a?(String) && key.length == 1
          # Do nothing, keep key as it is
        else
          key = KEY_NAME[key]
        end

        if key
          if (macro = xml.attributes['macro'])
            @key_binding[key] = proc { @do_macro.call(macro) }
          elsif xml.attributes['action'] && (action = actions[xml.attributes['action']])
            @key_binding[key] = action
          else
            @key_binding[key] ||= Hash.new
            xml.elements.each { |e| self.load_bindings(e, actions) }
          end
        end
      end
    end

    def handle_key(ch)
      handled = true
      if @key_combo
        if @key_combo[ch].class == Proc
          @key_combo[ch].call
          @key_combo = nil
        elsif @key_combo[ch].class == Hash
          @key_combo = @key_combo[ch]
        else
          @key_combo = nil
        end
      elsif @key_binding[ch].class == Proc
        @key_binding[ch].call
      elsif @key_binding[ch].class == Hash
        @key_combo = @key_binding[ch]
      else
        # just a character, let this fall through for the command window to display
        handled = false
      end
      return handled
    end


  end
end