class Screen

  def initialize(res)
    @res = res.to_i
    @rgb_grid = Array.new(res)
    @z_grid = Array.new(res)
    for i in (0...res)
      @rgb_grid[i] = Array.new(res)
      @z_grid[i] = Array.new(res)
      for j in (0...res)
        @rgb_grid[i][j] = $BACKGROUND_COLOR
        @z_grid[i][j] = -1*Float::MAX #minimum value >:c
      end
    end
  end

  def plot(x, y, z, r: $RC, g: $GC, b: $BC)
    y = @res - y.to_i
    x = x.to_i
    return if x < 0 || y < 0 || x >= @res || y >= @res
    if @z_grid[y][x] < z
      @z_grid[y][x] = z
      @rgb_grid[y][x] = [r.to_i, g.to_i, b.to_i]
    end
  end

  ## Write GRID to OUTFILE
  def write_out(file: $OUTFILE)
    puts "Writing out to #{file}" if $DEBUGGING
    extension = file.dup #filename with any extension
    file[file.index('.')..-1] = '.ppm'
    #$GRID = create_grid()
    outfile = File.open(file, 'w')
    outfile << "P3 #$RESOLUTION #$RESOLUTION 255\n" #Header in 1 line

    #Write PPM data
    for row in @rgb_grid
      for pixel in row
        for rgb in pixel
          outfile << rgb
          outfile << ' '
        end
        outfile << '   '
      end
      outfile << "\n"
    end
    outfile.close()

    #Convert filetype
    print %x[convert #{file} #{extension}]
    if not extension["ppm"]
      print %x[rm #{file}] end
  end


end
