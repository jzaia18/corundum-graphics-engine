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
$OBJ_FOLDER = "obj/"
$STEP = 12 # Number of iterations needed to to finish a parametric
$FRAMES = nil
$BASENAME = nil

# Static
$SCREEN = Screen.new($RESOLUTION)
$COORDSYS = CStack.new()
$RC = $DRAW_COLOR[0]; $GC = $DRAW_COLOR[1]; $BC = $DRAW_COLOR[2]
$AMBIENT_LIGHT = [150, 150, 150] #[r, g, b] (Default, if unspecified in mdl)
$POINT_LIGHTS = []
$CONSTANTS = {}
$Ka = [0.3, 0.3, 0.3] #Constant of ambient (Default, if unspecified in mdl)
$Kd = [0.5, 0.5, 0.5] #Constant of diffuse (Default, if unspecified in mdl)
$Ks = [0.5, 0.5, 0.5] #Constant of specular (Default, if unspecified in mdl)
$VIEW = [0, 0, 1]
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
