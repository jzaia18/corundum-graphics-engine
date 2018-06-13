require './CStack.rb'
require './Draw.rb'
require './Matrix.rb'
require './MatrixUtils.rb'
require './Utils.rb'
require './Screen.rb'

include Math

##TAU!!!!
$TAU = PI*2

# Changeable
$RESOLUTION = 500 # All images are squares
$DEBUGGING = false
$BACKGROUND_COLOR = [225, 225, 225] # [r, g, b]
$DRAW_COLOR = [200, 200, 200] # for 2D drawing
$INFILE = "script.mdl"
$OUTFILE = "image.ppm"
$TEMPFILE = "temmmmp.ppm" # Used as temp storage for displaying
$COMPYLED_CODE_LOC = "__COMPYLED_CODE__"
$OUTPUT_FOLDER = "anim/"
$STEP = 10 # Number of iterations needed to to finish a parametric
$AMBIENT_LIGHT = [50, 50, 50]
$POINT_LIGHT = [[0.5, 0.75, 1],
                [255, 12, 0]]
$VIEW = [0, 0, 1]
$FRAMES = nil
$BASENAME = nil

# Static
$SCREEN = Screen.new($RESOLUTION)
$COORDSYS = CStack.new()
$RC = $DRAW_COLOR[0]; $GC = $DRAW_COLOR[1]; $BC = $DRAW_COLOR[2]
$Ka = [0.1, 0.1, 0.1] #Constant of ambient
$Kd = [0.5, 0.5, 0.5] #Constant of diffuse
$Ks = [0.5, 0.5, 0.5] #Constant of specular
$ANIMATION = nil #Boolean representing whether output will be an animation (as opposed to a still image)
$KNOBFRAMES = nil

##=================== MAIN ==========================
### Take in script file

if ARGV[0]
  $INFILE = ARGV[0]
else
  puts "Please specify a file: (leave blank for \"script.mdl\")"
  got = gets.chomp
  $INFILE = got if got != ""
end


Utils.parse_file()
