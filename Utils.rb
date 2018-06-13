# coding: utf-8
include Math
require './Matrix.rb'
require './MatrixUtils.rb'
require './VectorUtils.rb'

module Utils

  def self.restrict(n, bot: 0, top: 255)
    return [[n, top].min, bot].max
  end

  # Calculates light at a point using Phong Reflection Model
  def self.calc_light(view, normal, ka, kd, ks)
    total_diff = [0, 0, 0]
    total_spec = [0, 0, 0]
    ambient = $AMBIENT_LIGHT.zip(ka).map{|x, y| x * y}

    v = VectorUtils.normalize(view)
    n = VectorUtils.normalize(normal)
    for light in $POINT_LIGHTS
      l = VectorUtils.normalize(light["location"])

      diffuse  = light["color"].zip(kd).map{|x, y| x * y}
      specular = light["color"].zip(ks).map{|x, y| x * y}

      costheta = VectorUtils.dot_product(l, n)
      temp = VectorUtils.dot_product(n, l)
      cosalpha = [VectorUtils.dot_product(n.map{|a| a*temp*2}.zip(l).map{|a, b| a - b}, v), 0].max**8
      diffuse  = diffuse.map{|x| x*costheta}
      specular = specular.map{|x| x*cosalpha}

      total_diff = total_diff.zip(diffuse).map{|x, y| x + y}
      total_spec = total_spec.zip(specular).map{|x, y| x + y}
    end

    return total_spec.zip(ambient.zip(total_diff).map{|x, y| x + y}).map{|x, y| x + y}.map{|x| restrict(x)} #exhales slowly
  end

  def self.write_out(file: $OUTFILE)
    $ANIMATION ? $SCREEN.write_out(file: $OUTPUT_FOLDER + file) : $SCREEN.write_out(file: file)
  end

  def self.display(tempfile: $TEMPFILE)
    write_out(file: tempfile)
    puts %x[display #{tempfile}]
    puts %x[rm #{tempfile}]
  end

  def self.format_compyled_code(code)
    code = code.gsub(",)", ", nil)")
    code = code.gsub("None", "nil")
    code = code.gsub("(", "[")
    code = code.gsub(")", "]")
    code = code.gsub("'", "\"")
    code = code.gsub(": ", "=>")
    return eval(code) #¯\_(ツ)_/¯
  end

  def self.parse_file(filename: $INFILE)
    puts %x[python compyler/main.py #{filename}]

    file = File.new($COMPYLED_CODE_LOC, "r")
    code = format_compyled_code(file.gets)
    file.close
    puts %x[rm #$COMPYLED_CODE_LOC]

    ops_list = code[0]
    symbol_table = code[1]

    #Parse for lights
    for var in symbol_table
      $POINT_LIGHTS.push(var[1][1]) if var[1][0] == "light"
      if var[1][0] == "constants"
        bad_format = var[1][1]

        temp = {"ka"=>[], "kd"=>[], "ks"=>[]}
        temp["ka"] = [bad_format["red"][0], bad_format["green"][0], bad_format["blue"][0]]
        temp["kd"] = [bad_format["red"][1], bad_format["green"][1], bad_format["blue"][1]]
        temp["ks"] = [bad_format["red"][2], bad_format["green"][2], bad_format["blue"][2]]

        $CONSTANTS[var[0]] = temp
        puts $CONSTANTS
      end
    end

    #parse for basic anim commands, throw duplicate errors
    for operation in ops_list
      case operation["op"]
      when "frames"
        raise "ERROR: Duplicate definition of frames" if $FRAMES
        $FRAMES = operation["args"][0]
        raise "ERROR: Frames must be a positive number" if $FRAMES <= 0
        puts "frames: #{operation["args"][0]}" if $DEBUGGING
      when "basename"
        raise "ERROR: Duplicate definition of basename" if $BASENAME
        $BASENAME = operation["args"][0]
        puts "basename: #{operation["args"][0]}" if $DEBUGGING
      when "vary"
        raise "ERROR: Vary called before definition of frames" if !$FRAMES
      end
    end
    ops_list = ops_list.delete_if{|x| x["op"] == "frames" or x["op"] == "basename" or x["op"]=="light" or x["op"]=="constants"} #Clear useless ops

    $ANIMATION = ($FRAMES != nil)
    $FRAMES = 1 if !$ANIMATION
    if !$BASENAME
      puts "WARNING: Basename is undefined, temporarily set to \"output\""
      $BASENAME = 'output'
    end

    if $ANIMATION #Still images have no vary
      $KNOBFRAMES = Array.new($FRAMES)
      for i in (0...$FRAMES)
        $KNOBFRAMES[i] = Hash.new()
      end
      for operation in ops_list
        if operation["op"] == "vary"
          raise "ERROR: Vary cannot begin before frame 0" if operation["args"][0] < 0
          raise "ERROR: Vary cannot end after the last frame" if operation["args"][1] >= $FRAMES
          raise "ERROR: Vary must be over at least one frame" if operation["args"][0] >= operation["args"][1]
          knoblen = operation["args"][1] - operation["args"][0]
          deltaknob = operation["args"][3] - operation["args"][2]
          for i in (0..knoblen)
            $KNOBFRAMES[i+operation["args"][0]][operation["knob"]] = operation["args"][2] + i*deltaknob/knoblen
          end
        end
      end
    end
    ops_list = ops_list.delete_if{|x| x["op"] == "vary"} #Clear useless ops

    for currframe in (0...$FRAMES)
      $SCREEN = Screen.new($RESOLUTION)
      $COORDSYS = CStack.new()
      for operation in ops_list
        knobs = $KNOBFRAMES[currframe] if $ANIMATION
        puts "Executing: " + operation.to_s if $DEBUGGING
        args = operation["args"]
        case operation["op"]
        when "line"
          for i in (0...6); args[i] = args[i].to_f end
          puts "   With arguments: "  + args.to_s if $DEBUGGING
          temp = Matrix.new(4,0)
          temp.add_col([args[0], args[1], args[2], 1])
          temp.add_col([args[3], args[4], args[5], 1])
          MatrixUtils.multiply($COORDSYS.peek(), temp)
          Draw.push_edge_matrix(temp)
        when "box"
          for i in (0...6); args[i] = args[i].to_f end
          puts "   With arguments: "  + args.to_s if $DEBUGGING
          temp = Matrix.new(4, 0)
          Draw.box(args[0], args[1], args[2], args[3], args[4], args[5], temp)
          MatrixUtils.multiply($COORDSYS.peek(), temp)
          if operation.has_key?("constants")
            ret = $CONSTANTS[operation["constants"]]
            Draw.push_polygon_matrix(temp, ka: ret["ka"], kd: ret["kd"], ks: ret["ks"])
          else
            Draw.push_polygon_matrix(temp)
          end
        when "sphere"
          for i in (0...4); args[i] = args[i].to_f end
          puts "   With arguments: "  + args.to_s if $DEBUGGING
          temp = Matrix.new(4, 0)
          Draw.sphere(args[0], args[1], args[2], args[3], temp)
          MatrixUtils.multiply($COORDSYS.peek(), temp)
          if operation.has_key?("constants")
            ret = $CONSTANTS[operation["constants"]]
            Draw.push_polygon_matrix(temp, ka: ret["ka"], kd: ret["kd"], ks: ret["ks"])
          else
            Draw.push_polygon_matrix(temp)
          end
        when "torus"
          for i in (0...5); args[i] = args[i].to_f end
          puts "   With arguments: "  + args.to_s if $DEBUGGING
          temp = Matrix.new(4, 0)
          Draw.torus(args[0], args[1], args[2], args[3], args[4], temp)
          MatrixUtils.multiply($COORDSYS.peek(), temp)
          if operation.has_key?("constants")
            ret = $CONSTANTS[operation["constants"]]
            Draw.push_polygon_matrix(temp, ka: ret["ka"], kd: ret["kd"], ks: ret["ks"])
          else
            Draw.push_polygon_matrix(temp)
          end
        when "clear"
          $SCREEN = Screen.new($RESOLUTION)
        when "scale"
          for i in (0...3); args[i] = args[i].to_f end
          puts "   With arguments: "  + args.to_s if $DEBUGGING
          puts "   And knobs: " + knobs.to_s if $DEBUGGING && $ANIMATION
          k = ($ANIMATION && knobs[operation["knob"]]? knobs[operation["knob"]]: 1)
          scale = MatrixUtils.dilation(k*args[0], k*args[1], k*args[2])
          $COORDSYS.modify_top(scale);
        when "move"
          for i in (0...3); args[i] = args[i].to_f end
          puts "   With arguments: "  + args.to_s if $DEBUGGING
          puts "   And knobs: " + knobs.to_s if $DEBUGGING && $ANIMATION
          k = ($ANIMATION && knobs[operation["knob"]]? knobs[operation["knob"]]: 1)
          move = MatrixUtils.translation(k*args[0], k*args[1], k*args[2])
          $COORDSYS.modify_top(move);
        when "rotate"
          puts "   With arguments: "  + args.to_s if $DEBUGGING
          puts "   And knobs: " + knobs.to_s if $DEBUGGING && $ANIMATION
          k = ($ANIMATION && knobs[operation["knob"]]? knobs[operation["knob"]]: 1)
          rotate = MatrixUtils.rotation(args[0], k*args[1].to_f)
          $COORDSYS.modify_top(rotate);
        when "ambient"
          $AMBIENT_LIGHT = args
        when "pop"
          $COORDSYS.pop()
        when "push"
          $COORDSYS.push()
        when "display"
          display();
        when "save"
          write_out(file: operation["args"][0] + ".png")
        when "quit", "exit"
          exit 0
        else
          puts "WARNING: Unrecognized command: " + operation.to_s
        end
      end
      if $ANIMATION
        fork do
          puts "FORK: frame #{currframe} created." if $DEBUGGING
          write_out(file: "%03d%s.png" % [currframe, $BASENAME])
          puts "FORK: frame #{currframe} finished."
        end
      end
    end
    if $ANIMATION
      Process.waitall
      print %x[convert #{$OUTPUT_FOLDER}/*#{$BASENAME}.png #{$BASENAME}.gif]
      print %x[rm #{$OUTPUT_FOLDER}/*#{$BASENAME}.png]
      print %x[animate #{$BASENAME}.gif]
    end
  end
end
